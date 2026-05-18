module datamem(
    input clk,
    input reset,

    input [3:0] addr, // 16 memorijskih lokacija
    input [7:0] wdata,
    input we,

    output [7:0] rdata
);

// 16 x 8 bit memorija
reg [7:0] mem [0:15];

// asinhrono čitanje
assign rdata = mem[addr];

integer i;

always @(posedge clk or posedge reset) begin

    // reset memorije
    if(reset)
        for(i=0;i<16;i=i+1)
            mem[i] <= 8'b0;

    // STORE operacija
    else if(we)
        mem[addr] <= wdata;

end

endmodule