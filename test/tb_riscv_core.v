`timescale 1ps/1ps

module tb_riscv_core;

    reg clk;
    reg rst_n;
    reg ena;

    reg [7:0] ui_in;
    reg [7:0] ext_in_tb;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_riscv_mini uut (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(ext_in_tb),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    initial clk = 0;
    always #5000 clk = ~clk;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb_riscv_core);

        rst_n = 0;
        ena = 0;
        ui_in = 0;
        ext_in_tb = 0;
        #20000;

        rst_n = 1;
        ena = 1;

        $display("\n=== START ===\n");

        //---------------------------------
        // INIT REGFILE
        //---------------------------------
        uut.core.regs.regs[0] = 8'd9;
        uut.core.regs.regs[1] = 8'd3;
        uut.core.regs.regs[2] = 8'd20;
        uut.core.regs.regs[3] = 8'd12;

        //---------------------------------
        // ALU TESTS
        //---------------------------------
        $display("---- ALU ----");

        ui_in = 8'b0000_0000; ext_in_tb = 8'b00100001; #10000;
        $display("ADD = %0d | uo_out=%0d", uut.core.regs.regs[0], uo_out);
       
        #10000;
        $display("uo_out = %0d,", uo_out);

        ui_in = 8'b0001_0101; ext_in_tb = 8'b00000010; #10000;
        $display("SUB = %0d | uo_out=%0d", uut.core.regs.regs[2], uo_out);

        #10000;
        $display("uo_out = %0d", uo_out);

        ui_in = 8'b0010_0000; ext_in_tb = 8'b00000011; #10000;
        $display("AND = %0d | uo_out=%0d", uut.core.regs.regs[0], uo_out);

        #10000;
        $display("uo_out = %0d", uo_out);

        ui_in = 8'b0011_0000; ext_in_tb = 8'b00000011; #10000;
        $display("OR  = %0d | uo_out=%0d", uut.core.regs.regs[0], uo_out);

        #10000;
        $display("uo_out = %0d", uo_out);

        //---------------------------------
        // SHIFT
        //---------------------------------
        $display("\n---- SHIFT ----");

        ui_in = 8'b1100_0001; ext_in_tb = 8'd1; #10000;
        $display("SLL = %0d | uo_out=%0d", uut.core.alu_i.y, uo_out);

        #10000;
        $display("uo_out = %0d", uo_out);

        ui_in = 8'b1110_0001; ext_in_tb = 8'd1; #10000;
        $display("SRL = %0d | uo_out=%0d", uut.core.alu_i.y, uo_out);

        #10000;
        $display("uo_out = %0d", uo_out);

        //---------------------------------
        // STORE
        //---------------------------------
        $display("\n---- STORE ----");

        uut.core.regs.regs[0] = 8'd4;
        uut.core.regs.regs[1] = 8'd55;

        ui_in = 8'b1000_0001;
        ext_in_tb = 8'b001_00000; #10000;

        $display("MEM[4] = %0d | uo_out=%0d", uut.core.mem.mem[4], uo_out);

        #10000;
        $display("uo_out = %0d", uo_out);

        //---------------------------------
        // LOAD
        //---------------------------------
        $display("\n---- LOAD ----");

        uut.core.regs.regs[0] = 8'd4;
       // uut.core.mem.mem[4] = 8'd11;

        ui_in = 8'b1010_0001;
        ext_in_tb = 8'b00000000; #10000;

        $display("LOAD R0 = %0d | uo_out=%0d", uut.core.regs.regs[0], uo_out);

        #10000;
        $display("uo_out = %0d", uo_out);

               //---------------------------------
        // LI -> STORE -> LOAD TEST
        //---------------------------------
        $display("\n---- LI -> STORE -> LOAD ----");

        // 1. LI: upiši 41 u R0
        ui_in = 8'b1001_0001;
        ext_in_tb = 8'd41; #10000;

        $display("After LI: R0 = %0d", uut.core.regs.regs[0]);

        #10000;
        $display("uo_out = %0d", uo_out);

        // 2. STORE: spremi R0 na adresu 4
        uut.core.regs.regs[1] = 8'd4;   // koristimo R1 kao adresu

        ui_in = 8'b1000_0011; // STORE opcode
        ext_in_tb = 8'b000_00001; #10000;

        $display("After STORE: MEM[4] = %0d", uut.core.mem.mem[4]);

        #10000;
        $display("uo_out = %0d", uo_out);

        // 3. LOAD: učitaj iz memorije nazad u R0
        uut.core.regs.regs[0] = 8'd4;   // očisti R0 da vidimo da se stvarno učitava

        ui_in = 8'b1010_0001; // LOAD opcode
        ext_in_tb = 8'd0; #10000;

        $display("After LOAD: R0 = %0d", uut.core.regs.regs[0]);

        #10000;
        $display("uo_out = %0d", uo_out);

        //---------------------------------
        // JAL + PC TEST
        //---------------------------------
        $display("\n---- JAL ----");

        // pretpostavka: PC postoji u core kao uut.core.pc
      //  uut.core.pc = 8'd10;

        ui_in = 8'b1011_0001;   // JAL opcode
        ext_in_tb = 8'd20;      // offset

        #10000;

       $display("PC after JALR = %0d, ", uut.core.pc);
        $display("uo_out = %0d", uo_out);

         #10000;
        $display("uo_out = %0d, rd = %0d", uo_out , uut.core.rd);


        $display("\n---- JAL ----");

        // pretpostavka: PC postoji u core kao uut.core.pc
      //  uut.core.pc = 8'd10;

        ui_in = 8'b0111_0001;   // JAL opcode
        ext_in_tb = 8'd20;      // offset

        #10000;

        $display("PC after JALR = %0d", uut.core.pc);
        $display("uo_out = %0d", uo_out);

         #10000;
        $display("uo_out = %0d", uo_out);

        //---------------------------------
        $display("\n=== END ===\n");
        $finish;
    end

endmodule