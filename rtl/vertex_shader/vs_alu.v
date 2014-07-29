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
parameter S_ALU_IDLE = 2'b00, 
          S_ALU_WAIT = 2'b01,
          S_ALU_COMP = 2'b10;

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
wire  wValid;
FFD_PosedgeAsync #(`SHADER_ALU_DATA_WIDTH) FFD_Valid(
  .clk(clk),
  .resetn(resetn),
  .D(iValid),
  .Q(wValid)
);
reg [7:0]                        counter;
reg                              rReady;
reg [`SHADER_ALU_DATA_WIDTH-1:0] rResult;
reg [`SHADER_ALU_DATA_WIDTH-1:0] rResultHi;
reg [1:0]                        state, next_state;

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        state <= S_ALU_IDLE;
    end else begin  
        state <= next_state;
    end 
end 

always @(*) begin 
    next_state = state ;
    case (state) 
        S_ALU_IDLE : begin 
                        next_state = wValid ? S_ALU_WAIT : S_ALU_IDLE;
                     end 
        S_ALU_WAIT : begin 
                        if (counter == ALU_MUL_DELAY && wALU_Op ==`OP_DP4 ) begin 
                            next_state = S_ALU_COMP;
                        end else   begin
                            next_state = S_ALU_WAIT;
                        end 
                     end 
        S_ALU_COMP : begin 
                        next_state = S_ALU_IDLE;
                     end 
    endcase 
end 

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        counter   <= 8'b0;
        rResult   <=`SHADER_ALU_DATA_WIDTH'b0;
        rResultHi <=`SHADER_ALU_DATA_WIDTH'b0;
        rReady    <= 1'b0;
    end else begin 
        case (state)
            S_ALU_IDLE : begin 
                             counter   <= 8'b0;
                             rReady    <= 1'b0;
                             rResult   <=`SHADER_ALU_DATA_WIDTH'b0;
                             rResultHi <=`SHADER_ALU_DATA_WIDTH'b0;
                         end 
            S_ALU_WAIT : begin 
                             counter   <= counter + 8'b1;
                             rReady    <= 1'b0;
                             rResult   <=`SHADER_ALU_DATA_WIDTH'b0;
                             rResultHi <=`SHADER_ALU_DATA_WIDTH'b0;
                         end 
            S_ALU_COMP : begin 
                             counter             <= 8'b0;
                             if (wALU_Op ==`OP_DP4) begin 
                                 rReady              <= 1'b1;
                                 {rResultHi,rResult} <= wA*wB;
                             end 
                         end  
        endcase 
    end 
end 

assign oReady  = rReady;
assign oResult = rResult;
assign oZero   = rResult == 32'b0 ? 1'b1 : 1'b0; 
assign oOverflow = rResultHi != 32'b0;

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
parameter S_ALU_IDLE = 2'b00, 
          S_ALU_WAIT = 2'b01,
          S_ALU_COMP = 2'b10;
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
reg                              rOverflow;
reg [1:0]                        state, next_state;

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        state <= S_ALU_IDLE;
    end else begin  
        state <= next_state;
    end 
end 

always @(*) begin 
    next_state = state ;
    case (state) 
        S_ALU_IDLE : begin 
                        next_state = wValid ? S_ALU_WAIT : S_ALU_IDLE;
                     end 
        S_ALU_WAIT : begin 
                        if (counter==ALU_ACC_DELAY)
                            next_state = S_ALU_COMP;
                        else  
                            next_state = S_ALU_WAIT;
                     end 
        S_ALU_COMP : begin 
                        next_state = S_ALU_IDLE;
                     end 
    endcase 
end 

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        counter   <= 8'b0;
        rResult   <=`SHADER_ALU_DATA_WIDTH'b0;
        rReady    <= 1'b0;
        rOverflow <= 1'b0;
    end else begin 
        case (state)
            S_ALU_IDLE : begin 
                             counter   <= 8'b0;
                             rReady    <= 1'b0;
                             rResult   <=`SHADER_ALU_DATA_WIDTH'b0;
                             rOverflow <= 1'b0;
                         end 
            S_ALU_WAIT : begin 
                             counter   <= counter + 8'b1;
                             rReady    <= 1'b0;
                             rResult   <=`SHADER_ALU_DATA_WIDTH'b0;
                             rOverflow <= 1'b0;
                         end 
            S_ALU_COMP : begin 
                             counter             <= 8'b0;
                             rReady              <= 1'b1;
                             {rOverflow,rResult} <= wX + wY + wZ + wW;
                         end  
        endcase 
    end 
end 
assign oReady  = rReady;
assign oResult = rResult;
assign oZero   = rResult ==32'b0 ? 1'b1 : 1'b0;
assign oOverflow = rOverflow;

endmodule 


