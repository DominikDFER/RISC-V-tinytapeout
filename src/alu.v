module alu(
    input [7:0] a,
    input [7:0] b,
    input [3:0] op,
    output reg [7:0] y
);

always @(*) begin
    case(op)
        4'b0000: y = a + b;   // ADD
        4'b0001: y = a - b;   // SUB
        4'b0010: y = a & b;   // AND
        4'b0011: y = a | b;   // OR
        4'b1100: y = a << b;   // SLL
        4'b1110: y = a >> b;   // SRL
        default: y = 8'b0;
    endcase
end

endmodule