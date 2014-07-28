`define OP_ADD `SHADER_ALU_OP_WIDTH'b000001
`define OP_MAX `SHADER_ALU_OP_WIDTH'b000010
`define OP_MIN `SHADER_ALU_OP_WIDTH'b000011
`define OP_MUL `SHADER_ALU_OP_WIDTH'b000100
`define OP_DP3 `SHADER_ALU_OP_WIDTH'b100001
`define OP_DP4 `SHADER_ALU_OP_WIDTH'b100010
//vs_core.v
`define SHADER_CORE_DATA_WIDTH 128
`define SHADER_CORE_X_RANGE 127:96
`define SHADER_CORE_Y_RANGE  95:64
`define SHADER_CORE_Z_RANGE  63:32
`define SHADER_CORE_W_RANGE  31:0
//vs_alu.v
`define SHADER_ALU_DATA_WIDTH 32
`define SHADER_ALU_OP_WIDTH    6
//vs_common_uitls.v
`define DATA_WIDTH 32
