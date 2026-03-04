`default_nettype none

module tt_um_riscv_mini (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

wire [15:0] instruction;
assign instruction = {uio_in, ui_in};

wire [7:0] cpu_out;

riscv_core core (
    .clk(clk),
    .rst_n(rst_n),
    .instruction(instruction),
    .out_port(cpu_out)
);

assign uo_out = cpu_out;

// Ne koristimo bidirectional pinove za izlaz
assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

endmodule