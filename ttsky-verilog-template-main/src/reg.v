module reg_file(
    input wire clk,
    input wire rst_n,
    input wire [1:0] rs1,
    input wire [1:0] rs2,
    input wire [1:0] rd,
    input wire [7:0] write_data,
    input wire reg_write,
    output wire [7:0] read_data1,
    output wire [7:0] read_data2
);

reg [7:0] regs [3:0];

assign read_data1 = regs[rs1];
assign read_data2 = regs[rs2];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        regs[0] <= 8'd0;
        regs[1] <= 8'd0;
        regs[2] <= 8'd0;
        regs[3] <= 8'd0;
    end
    else if (reg_write) begin
        regs[rd] <= write_data;
    end
end

endmodule