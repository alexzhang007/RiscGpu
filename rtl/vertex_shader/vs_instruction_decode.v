//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : 07-29-2014
//Description : Behavior model of shader_instruction_decode that decodes the vertex_program 
//              The supported instruction see the Section 2.14.2 in
//              http://www.opengl.org/registry/specs/ARB/vertex_program.txt
module shader_instruction_decode (
clk,
resetn,
iValid,
iInstruction,
oReady,
oALU_Op,
oDestWriteMask,
oDestReg,
oSrc0Reg,
oSrc0RegData,
oSrc1RegData
);
input  clk;
input  resetn;
input  iValid;
input  iInstruction;
output oReady;
output oALU_Op;
output oDestWriteMask;
output oDestReg;
output oSrc0Reg;
output oSrc0RegData;
output oSrc1RegData;

wire                               iValid;
wire [`INST_WIDTH-1:0]             iInstruction;
wire [`INST_OP_WIDTH-1:0]          oALU_Op;
wire [`INST_DWM_WIDTH-1:0]         oDestWriteMask;
wire [`INST_REG_WIDTH-1:0]         oDestReg;
wire [`INST_REG_WIDTH-1:0]         oSrc0Reg;
wire [`SHADER_CORE_DATA_WIDTH-1:0] oSrc0RegData;
wire [`SHADER_CORE_DATA_WIDTH-1:0] oSrc1RegData;
wire                               oReady;
wire  wValid;
FFD_PosedgeAsync #(`SHADER_ALU_DATA_WIDTH) FFD_Valid(
  .clk(clk),
  .resetn(resetn),
  .D(iValid),
  .Q(wValid)
);

wire [`INST_WIDTH-1:0]     wInstruction;
FFD_PosedgeAsyncEnable #(`INST_WIDTH) FFD_W(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iInstruction),
  .Q(wInstruction)
);

reg [`INST_OP_WIDTH-1:0]  rOp;
reg [`INST_DWM_WIDTH-1:0] rDestWriteMask;
reg [`INST_REG_WIDTH-1:0] rDestReg;
reg [`INST_REG_WIDTH-1:0] rSrc0Reg;
reg [`INST_REG_WIDTH-1:0] rSrc1Reg;

always @(*) begin
    rOp            = {wInstruction[`INST_OP_RANGE],wInstruction[`INST_EX_OP_RANGE]};
    rDestWriteMask = wInstruction[`INST_DWM_RANGE];
    rDestReg       = wInstruction[`INST_DR_RANGE];
    rSrc0Reg       = wInstruction[`INST_S0R_RANGE];
    rSrc1Reg       = wInstruction[`INST_S1R_RANGE];
end 

wire wReady;
wire [`SHADER_CORE_DATA_WIDTH-1:0] wSrc0RegData;
wire [`SHADER_CORE_DATA_WIDTH-1:0] wSrc1RegData;
shader_register_file reg_file (
  .clk(clk),
  .resetn(resetn),
  .iValid(wValid),
  .iSrc0Reg(rSrc0Reg),
  .iSrc1Reg(rSrc1Reg),
  .oReady(wReady),
  .oSrc0RegData(wSrc0RegData),
  .oSrc1RegData(wSrc1RegData)
);
assign oReady   = wReady;
assign oALU_Op  = rOp;
assign oDestWriteMask = rDestWriteMask;
assign oDestReg = rDestReg;
assign oSrc0Reg = rSrc0Reg;
assign oSrc0RegData = wSrc0RegData;
assign oSrc1RegData = wSrc1RegData;

endmodule 
