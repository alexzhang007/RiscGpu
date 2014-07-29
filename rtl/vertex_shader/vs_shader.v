//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : 07-29-2014
//Description : Behavior model of vertex shader which has the attribute registers.
module vertex_shader (
clk,
resetn,
iValid,
iA,
iB,
iALU_Op,
oReady,
oResult,


);


shader_instruction_decode  ID_Unit(
  .clk(clk),
  .resetn(resetn),
  .iValid(wValidID),
  .iInstruction,
  .oReady(wReadyID),
  .oALU_Op(wALU_Op),
  .oDestWriteMask(wDestWriteMaskID),
  .oDestReg(wDestRegID),
  .oSrc0Reg(wSrc0RegID),
  .oSrc0RegData(wSrc0RegDataID),
  .oSrc1RegData(wSrc1RegDataID)
);


shader_core EXE_Unit(
  .clk(clk),
  .resetn(resetn),
  .iValid(wReadyID),
  .iA(wSrc0RegDataID),
  .iB(wSrc1RegDataID),
  .iALU_Op(),
  .oReady(),
  .oResult(),
  .oZero(),
  .oOverflow
);


endmodule 
