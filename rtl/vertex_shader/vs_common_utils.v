//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : 07-28-2014
//Description : vertex_shader common util module
`include "vs_defines.vh"
module FFD_PosedgeAsync#(parameter DW=`DATA_WIDTH) (
clk,
resetn,
D,
Q
);
input  clk;
input  resetn;
input  D;
output Q;
wire [DW-1:0] D;
reg  [DW-1:0] Q;

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        Q <= {DW{1'b0}};
    end else begin 
        Q <= D;
    end 

end 
endmodule 

//Latch
module FFD_PosedgeAsyncEnable#(parameter DW=`DATA_WIDTH) (
clk,
resetn,
Enable,
D,
Q
);
input  clk;
input  resetn;
input  Enable;
input  D;
output Q;
wire [DW-1:0] D;
reg  [DW-1:0] Q;

always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        Q <= {DW{1'b0}};
    end else begin 
        if (Enable)
            Q <= D;
    end 

end 
endmodule
