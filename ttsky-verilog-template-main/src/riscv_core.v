module riscv_core(
    input wire clk,
    input wire rst_n,
    input wire [15:0] instruction,
    output wire [7:0] out_port
);

// =====================
// Dekodiranje instrukcije
// =====================

wire [2:0] opcode = instruction[15:13];
wire [1:0] rd     = instruction[12:11];
wire [1:0] rs1    = instruction[10:9];
wire [1:0] rs2    = instruction[8:7];
wire [1:0] funct  = instruction[6:5];
wire [2:0] imm3   = instruction[2:0];

// =====================
// Register file
// =====================

wire [7:0] regData1;
wire [7:0] regData2;
wire [7:0] writeData;
wire regWrite;

reg_file rf(
    .clk(clk),
    .rst_n(rst_n),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(writeData),
    .reg_write(regWrite),
    .read_data1(regData1),
    .read_data2(regData2)
);

// =====================
// ALU
// =====================

wire [7:0] alu_in2;

assign alu_in2 = (opcode == 3'b001 ||  // ADDI
                  opcode == 3'b010 ||  // LOAD
                  opcode == 3'b011)    // STORE
                  ? {5'b00000, imm3}
                  : regData2;

wire [7:0] alu_result;

alu alu_unit(
    .a(regData1),
    .b(alu_in2),
    .alu_control(funct),
    .result(alu_result)
);

// =====================
// Data Memory (4 lokacije)
// =====================

wire [7:0] memData;

data_mem dmem(
    .clk(clk),
    .mem_write(opcode == 3'b011),
    .addr(alu_result[1:0]),
    .write_data(regData2),
    .read_data(memData)
);

// =====================
// Writeback logika
// =====================

assign writeData =
    (opcode == 3'b010) ? memData : alu_result;

assign regWrite =
    (opcode == 3'b000) || // R-type
    (opcode == 3'b001) || // ADDI
    (opcode == 3'b010);   // LOAD

assign out_port = regData1;

endmodule