//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : 07-28-2014
//Description : Behavior model of vertex shader ALU
`include "vs_defines.vh"
module shader_alu (
clk,
resetn,
iValid,
iA,
iB,
iALU_Op,
oResult,
oReady,
oZero,
oOverflow
);
parameter ALU_MUL_DELAY = 8;
parameter ALU_ADD_DELAY = 8;
input clk;
input resetn;
input iValid;
input iA;
input iB;
input iALU_Op;
output oResult;
output oReady;
output oZero;
output oOverflow;
wire                              iValid;
wire [`SHADER_ALU_DATA_WIDTH-1:0] iA;
wire [`SHADER_ALU_DATA_WIDTH-1:0] iB;
wire [`SHADER_ALU_OP_WIDTH-1:0]   iALU_Op;
wire [`SHADER_ALU_DATA_WIDTH-1:0] oResult;
wire                              oZero;
wire                              oOverflow;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wA;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wB;
wire [`SHADER_ALU_OP_WIDTH-1:0]   wALU_Op;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_A(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iA),
  .Q(wA)
);
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_B(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iB),
  .Q(wB)
);
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_Op(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iALU_Op),
  .Q(wALU_Op)
);

reg [7:0] counter;
reg [`SHADER_ALU_DATA_WIDTH-1:0] rResult;
reg       rReady;

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        counter <= 8'h0;
        rReady <= 1'b0;
        rResult <=`SHADER_ALU_DATA_WIDTH'b0;
    end else begin 
        counter <= iValid ? 8'b0 : counter + 8'b1;
        if (counter == ALU_MUL_DELAY && wALU_Op ==`OP_DP4 ) begin 
           rResult <= wA * wB; 
           rReady  <= 1'b1;
        end else begin 
           rReady  <= 1'b0;
           rResult <= `SHADER_ALU_DATA_WIDTH'b0;
        end 
    end 
end 

assign oReady  = rReady;
assign oResult = rResult;
assign oZero   = rResult == 32'b0 ? 1'b1 : 1'b0; 
assign oOverflow = 1'b0;

endmodule  //shader_alu

//Four Add is seperated into 2 branches. 
//
module shader_accumulator (
clk,
resetn,
iValid,
iX,
iY,
iZ,
iW,
oResult,
oReady,
oZero,
oOverflow
);
parameter ALU_ACC_DELAY = 12;//Single Add is 6 cycles 
input  clk;
input  resetn;
input  iValid;
input  iX;
input  iY;
input  iZ;
input  iW;
output oResult;
output oReady;
output oZero;
output oOverflow;
wire                              iValid;
wire [`SHADER_ALU_DATA_WIDTH-1:0] iX;
wire [`SHADER_ALU_DATA_WIDTH-1:0] iY;
wire [`SHADER_ALU_DATA_WIDTH-1:0] iZ;
wire [`SHADER_ALU_DATA_WIDTH-1:0] iW;
wire [`SHADER_ALU_DATA_WIDTH-1:0] oResult;
wire                              oZero;
wire                              oOverflow;
wire                              oReady;

reg  [7:0] counter;
wire [`SHADER_ALU_DATA_WIDTH-1:0] wX;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_X(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iX),
  .Q(wX)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wY;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_Y(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iY),
  .Q(wY)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wZ;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_Z(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iZ),
  .Q(wZ)
);
wire [`SHADER_ALU_DATA_WIDTH-1:0] wW;
FFD_PosedgeAsyncEnable #(`SHADER_ALU_DATA_WIDTH) FFD_W(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iW),
  .Q(wW)
);
wire  wValid;
FFD_PosedgeAsync #(`SHADER_ALU_DATA_WIDTH) FFD_Valid(
  .clk(clk),
  .resetn(resetn),
  .D(iValid),
  .Q(wValid)
);

reg [`SHADER_ALU_DATA_WIDTH-1:0] rResult;
reg                              rReady; 
always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        counter <= 8'b0;
        rResult <=`SHADER_ALU_DATA_WIDTH'b0;
        rReady  <= 1'b0;
    end else begin 
        counter <= wValid ? 8'b0: counter + 8'b1;
        if (counter == ALU_ACC_DELAY) begin  
            rReady  <= 1'b1;
            rResult <= wX + wY + wZ + wW;
        end else begin 
            rReady  <= 1'b0;
            rResult <=`SHADER_ALU_DATA_WIDTH'b0;
        end 
    end 
end 
assign oReady  = rReady;
assign oResult = rResult;
assign oZero   = rResult ==32'b0 ? 1'b1 : 1'b0;
assign oOverflow = 1'b0;

endmodule 


