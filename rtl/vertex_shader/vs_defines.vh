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
//vs_instruction_decode.v
//{instruction[3:0],instruction[28:31]}
`define OP_NOP 8'b0000_0000
`define OP_ARL 8'b0000_0001  //ARL Instruction
`define OP_ABS 8'b0000_0010
`define OP_FLR 8'b0000_0011
`define OP_FRC 8'b0000_0100
`define OP_LIT 8'b0000_0101
`define OP_MOV 8'b0000_0110
`define OP_EX2 8'b0000_0111 //Scalar instrution
`define OP_EXP 8'b0000_1000
`define OP_LG2 8'b0000_1001
`define OP_LOG 8'b0000_1010  
`define OP_RCP 8'b0000_1011 
`define OP_RSQ 8'b0000_1100
`define OP_JMP 8'b0000_1101
`define OP_POW 8'b0001_0000 //BinSc instruction
`define OP_ADD 8'b0010_0000 //Bin instruction
`define OP_DP3 8'b0011_0000
`define OP_DP4 8'b0100_0000
`define OP_DPH 8'b0101_0000
`define OP_DST 8'b0110_0000
`define OP_MAX 8'b0111_0000
`define OP_MIN 8'b1000_0000
`define OP_MUL 8'b1001_0000
`define OP_SGE 8'b1010_0000
`define OP_SLT 8'b1011_0000
`define OP_SUB 8'b1100_0000
`define OP_XPD 8'b1101_0000
`define OP_MAD 8'b1110_0000 //TRI instruction
`define OP_SWZ 8'b1111_0000 //SWZ instruction

`define INST_REG_WIDTH    8
`define INST_WIDTH        32
`define INST_OP_RANGE     3:0
`define INST_DWM_RANGE    7:4
`define INST_DR_RANGE     15:8
`define INST_S0R_RANGE    23:16
`define INST_S1R_RANGE    31:24
`define INST_EXT_OP_RANGE 31:28
`define INST_OP_WIDTH     8
`define INST_DWM_WIDTH    4

//vs_register_file.v
`define REG_DATA_WIDTH 128
`define GP_DEPTH       240
`define TU_DEPTH       14
`define VA_DEPTH       16
