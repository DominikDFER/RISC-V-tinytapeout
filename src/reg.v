module regfile(
    input clk,
    input reset,

    input [2:0] ra, // read address A
    input [2:0] rb, // read address B
    input [2:0] wa, // write address

    input [7:0] wd, // write data
    input we,       // write enable

    output [7:0] rd_a,
    output [7:0] rd_b
);

// 4 registra po 8 bitova
reg [7:0] regs [0:7];

// asinhrono čitanje
assign rd_a = regs[ra];
assign rd_b = regs[rb];

integer i;

always @(posedge clk or posedge reset) begin
    if(reset)
        for(i=0;i<4;i=i+1)
            regs[i] <= 8'b0;

    else if(we)
        regs[wa] <= wd;
end

endmodule