module tt_um_riscv_mini (
    input  wire [7:0] ui_in,      // dedicated input
    output wire [7:0] uo_out,     // dedicated output

    input  wire [7:0] uio_in,     // bidirectional (nije korišten)
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire clk,
    input  wire rst_n,
    input  wire ena
);

wire reset = ~rst_n;
wire [7:0] cpu_out;


riscv_core core (
    .clk(clk),
    .reset(reset),
    .instr(ui_in),
    .ext_in(uio_in),
    .out_data(cpu_out)
);

assign uo_out   = cpu_out;
assign uio_out  = 8'b0;
assign uio_oe   = 8'b0;
wire _unused = &{ena, uio_in};

endmodule