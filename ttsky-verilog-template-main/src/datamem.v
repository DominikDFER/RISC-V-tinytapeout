module data_mem(
    input wire clk,
    input wire mem_write,
    input wire [1:0] addr,
    input wire [7:0] write_data,
    output wire [7:0] read_data
);

reg [7:0] mem [3:0];

assign read_data = mem[addr];

always @(posedge clk) begin
    if (mem_write)
        mem[addr] <= write_data;
end

endmodule