//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : 07-28-2014
//Description : Behavior model of vertex shader ALU assemble core. There will be 4 shader_alu in shader_core since the DP4 instruction has 4 operation together. 
`include "vs_defines.vh"
module shader_core(
clk,
resetn,
iValid,
iA,
iB,
iALU_Op,
oReady,
oResult
);
input  clk;
input  resetn;
input  iValid;
input  iA;
input  iB;
input  iALU_Op;
output oResult;
output oReady;
wire iValid;
wire [`SHADER_CORE_DATA_WIDTH-1:0] iA;
wire [`SHADER_CORE_DATA_WIDTH-1:0] iB;
wire [`SHADER_ALU_OP_WIDTH-1:0]    iALU_Op;
wire [`SHADER_ALU_DATA_WIDTH-1:0]  oResult;
wire                               oReady;

wire wReady_X;
wire wReady_Y;
wire wReady_Z;
wire wReady_W;
wire wZero_X;
wire wZero_Y;
wire wZero_Z;
wire wZero_W;
wire wOverflow_X;
wire wOverflow_Y;
wire wOverflow_Z;
wire wOverflow_W;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wResult_X;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wResult_Y;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wResult_Z;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wResult_W;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wA_X;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_AX(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iA[`SHADER_CORE_X_RANGE]),
  .Q(wA_X)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wA_Y;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_AY(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iA[`SHADER_CORE_Y_RANGE]),
  .Q(wA_Y)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wA_Z;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_AZ(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iA[`SHADER_CORE_Z_RANGE]),
  .Q(wA_Z)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wA_W;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_AW(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iA[`SHADER_CORE_W_RANGE]),
  .Q(wA_W)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wB_X;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_BX(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iB[`SHADER_CORE_X_RANGE]),
  .Q(wB_X)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wB_Y;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_BY(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iB[`SHADER_CORE_Y_RANGE]),
  .Q(wB_Y)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wB_Z;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_BZ(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iB[`SHADER_CORE_Z_RANGE]),
  .Q(wB_Z)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wB_W;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_BW(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iB[`SHADER_CORE_W_RANGE]),
  .Q(wB_W)
);
wire wValid;
FFD_PosedgeAsync #(1) FFD_Valid(
  .clk(clk),
  .resetn(resetn),
  .D(iValid),
  .Q(wValid)
);
wire [`SHADER_ALU_OP_WIDTH-1:0] wALU_Op;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_OP_WIDTH) FFD_Op(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iALU_Op),
  .Q(wALU_Op)
);

reg rValid_X;
reg rValid_Y;
reg rValid_Z;
reg rValid_W;
reg rValid_ACC;
wire wReady_X;
wire wReady_Y;
wire wReady_Z;
wire wReady_W;
always @(*) begin 
    case (wALU_Op) 
        `OP_DP3 : begin 
                      rValid_X= wValid; 
                      rValid_Y= wValid; 
                      rValid_Z= wValid; 
                      rValid_W= 1'b0; 
                      rValid_ACC = wReady_X & wReady_Y & wReady_Z;
                  end 
        `OP_DP4 : begin 
                      rValid_X= wValid; 
                      rValid_Y= wValid; 
                      rValid_Z= wValid; 
                      rValid_W= wValid; 
                      rValid_ACC = wReady_X & wReady_Y & wReady_Z & wReady_W;
                  end 
         default: begin 
                      rValid_X= 1'b0; 
                      rValid_Y= 1'b0; 
                      rValid_Z= 1'b0; 
                      rValid_W= 1'b0; 
                      rValid_ACC = 1'b0;
                      
                  end 
    endcase  
end 


shader_alu ALU_X (
 .clk(clk),
 .resetn(resetn),
 .iValid(rValid_X),
 .iA(wA_X),
 .iB(wB_X),
 .iALU_Op(wALU_Op),
 .oResult(wResult_X),
 .oReady(wReady_X),
 .oZero(wZero_X),
 .oOverflow(wOverflowX)
);
shader_alu ALU_Y (
 .clk(clk),
 .resetn(resetn),
 .iValid(rValid_Y),
 .iA(wA_Y),
 .iB(wB_Y),
 .iALU_Op(wALU_Op),
 .oResult(wResult_Y),
 .oReady(wReady_Y),
 .oZero(wZero_Y),
 .oOverflow(wOverflowY)
);
shader_alu ALU_Z (
 .clk(clk),
 .resetn(resetn),
 .iValid(rValid_Z),
 .iA(wA_Z),
 .iB(wB_Z),
 .iALU_Op(wALU_Op),
 .oResult(wResult_Z),
 .oReady(wReady_Z),
 .oZero(wZero_Z),
 .oOverflow(wOverflowZ)
);
shader_alu ALU_W (
 .clk(clk),
 .resetn(resetn),
 .iValid(rValid_W),
 .iA(wA_W),
 .iB(wB_W),
 .iALU_Op(wALU_Op),
 .oResult(wResult_W),
 .oReady(wReady_W),
 .oZero(wZero_W),
 .oOverflow(wOverflowW)
);
wire [`SHADER_ALU_DATA_WIDTH -1:0] wResult_ACC;
wire                               wReady_ACC;
wire                               wZero_ACC;
wire                               wOverflow_ACC;

shader_accumulator ACC (
 .clk(clk),
 .resetn(resetn),
 .iValid(rValid_ACC),
 .iX(wResult_X),
 .iY(wResult_Y),
 .iZ(wResult_Z),
 .iW(wResult_W),
 .oResult(wResult_ACC),
 .oReady(wReady_ACC),
 .oZero(wZero_ACC),
 .oOverflow(wOverflow_ACC)
);

assign oResult = wResult_ACC;
assign oReady  = wReady_ACC;

endmodule 
