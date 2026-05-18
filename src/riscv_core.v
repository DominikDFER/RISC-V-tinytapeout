module riscv_core(
    input clk,
    input reset,
    input [7:0] instr,
    input [7:0] ext_in,
    output [7:0] out_data
);

// dekodirani dijelovi instrukcije
wire [3:0] opcode; // operacija ALU / LOAD / STORE
wire [2:0] wa;     // write address (regfile)
wire [2:0] ra;     // read register A
wire [2:0] rb;     // read register B

// kontrolni signali
wire reg_we; // write enable za regfile
wire mem_we; // write enable za memoriju

// podaci iz regfile
wire [7:0] reg_a_data;
wire [7:0] reg_b_data;


// rezultat ALU
wire [7:0] alu_out;

// output memorije
wire [7:0] mem_out;

// podatak koji se upisuje u regfile
wire [7:0] write_data;

wire [7:0] operand_b;
wire [7:0] imm;
assign imm = ext_in;

reg phase; // 0 = FETCH, 1 = EXECUTE

always @(posedge clk or posedge reset) begin
    if (reset)
        phase <= 1'b0;
    else
        phase <= ~phase; // toggle svaki takt
end

assign operand_b = instr[0] ? imm : reg_b_data;


wire is_jal;
assign is_jal = (opcode == 4'b1011);

wire is_jalr;
assign is_jalr = (opcode == 4'b0111);

// -----------------------------
// PC
// -----------------------------
reg [7:0] pc;
reg [7:0] rd;
always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 8'b0;
    else if (phase) begin
    if (is_jal) begin
        rd  <= pc + 1;
        pc <= pc + ext_in;
    end
    else if(is_jalr)
       pc <= rd;
    else
        pc <= pc + 1;
        end
end


// -----------------------------
// DEKODER INSTRUKCIJE
// -----------------------------

assign opcode = instr[7:4]; // gornja 3 bita
assign ra     = instr[3:1];
assign rb     = ext_in[7:5];
assign wa = instr[3:1];




// regfile write enable (osim STORE instrukcije)
assign reg_we = (opcode != 4'b1000 && opcode != 4'b1011 && opcode != 4'b0111);

// memorija write enable samo za STORE
assign mem_we =  (opcode == 4'b1000);


// LOAD instrukcija koristi memorijski output
assign write_data = (opcode == 4'b1010) ? mem_out : (opcode == 4'b1001 && instr[0]) ? imm : alu_out;


// -----------------------------
// REGFILE
// -----------------------------

regfile regs(
    .clk(clk),
    .reset(reset),
    .ra(ra),
    .rb(rb),
    .wa(wa),
    .wd(write_data),
    .we(reg_we),
    .rd_a(reg_a_data),
    .rd_b(reg_b_data)
);


// -----------------------------
// ALU
// -----------------------------

alu alu_i(
    .a(reg_a_data),
    .b(operand_b),
    .op(opcode),
    .y(alu_out)
);


// -----------------------------
// DATA MEMORY
// -----------------------------

datamem mem(
    .clk(clk),
    .reset(reset),
    .addr(reg_a_data[3:0]), // 16 lokacija
    .wdata(reg_b_data),
    .we(mem_we),
    .rdata(mem_out)
);


// -----------------------------
// OUTPUT REGISTER
// -----------------------------

reg [7:0] out_reg;

always @(posedge clk or posedge reset) begin
    if (reset)
        out_reg <= 8'b0;
    else if (is_jal)
        out_reg <= pc+ext_in;   
   else if (is_jalr)
        out_reg <= rd; 
    else
        out_reg <= write_data;
end

assign out_data = (phase == 1'b0) ? out_reg : pc;

endmodule
