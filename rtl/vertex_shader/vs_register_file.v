//Author      : Alex Zhang (cgzhangwei@gmail.com)
//Date        : 07-29-2014
//Description : Behavior model of register file include the general purpose registers and vertex attribute
//              Program Counter register can only be read. It is shadowed the PC in the fetch stage. 
//              DestWriteMask need to be pipelined to next stage
//              Up to 240 128-bit registers  - General Purpose register - program.env[0]
//              Up to 14 texture units       - Texture Unit registers  
//              2 8-bit register             - Index Register           - index the vertex attribute
//              16-bit register              - Program Register         - 
//              When access the vertex attribute, need to MOV instruction to write the index register firstly.
module shader_register_file (
clk,
resetn,
iValid,
iSrc0Reg,
iSrc1Reg,
oReady,
oSrc0RegData,
oSrc1RegData
);
input  clk;
input  resetn;
input  iValid;
input  iAccessGeneralReg;
input  iAccessTextureReg;
input  iAccessIndexReg;
input  iAccessPC; 
input  iAccessVertexAttribute;
input  iSrc0Reg;
input  iSrc1Reg;
output oReady;
output oSrc0RegData;
output oSrc1RegData;

wire iValid;
wire iAccessGeneralReg;
wire iAccessTextureReg;
wire iAccessIndexReg;
wire iAccessPC; 
wire iAccessVertexAttribute;
wire [`INST_REG_WIDTH-1:0]         iSrc0Reg;
wire [`INST_REG_WIDTH-1:0]         iSrc1Reg;
wire                               oReady;
wire [`SHADER_CORE_DATA_WIDTH-1:0] oSrc0RegData;
wire [`SHADER_CORE_DATA_WIDTH-1:0] oSrc1RegData;

wire  wValid;
FFD_PosedgeAsync #(`SHADER_ALU_DATA_WIDTH) FFD_Valid(
  .clk(clk),
  .resetn(resetn),
  .D(iValid),
  .Q(wValid)
);
wire wValidPP1;
FFD_PosedgeAsync #(`SHADER_ALU_DATA_WIDTH) FFD_ValidPP1(
  .clk(clk),
  .resetn(resetn),
  .D(wValid),
  .Q(wValidPP1)
);
wire [`INST_REG_WIDTH-1:0]         wSrc0Reg;
wire [`INST_REG_WIDTH-1:0]         wSrc1Reg;
FFD_PosedgeAsyncEnable #(`INST_REG_WIDTH) FFD_Src0(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iSrc0Reg),
  .Q(wSrc0Reg)
);
FFD_PosedgeAsyncEnable #(`INST_REG_WIDTH) FFD_Src1(
  .clk(clk),
  .resetn(resetn),
  .Enable(iValid),
  .D(iSrc1Reg),
  .Q(wSrc1Reg)
);
//Using double port RAM to synthesize the register memory. 
reg rEnable0PC;
reg rEnable0GP;
reg rEnable0VA;
reg rEnable0TU;
reg rEnable0IX0;
reg rEnable0IX1;
reg rEnable0Wr;
reg rEnable1PC;
reg rEnable1GP;
reg rEnable1VA;
reg rEnable1TU;
reg rEnable1IX0;
reg rEnable1IX1;
reg rEnable1Wr;
reg [`REG_DATA_WIDTH-1:0] memGenPurp[`GP_DEPTH-1:0];
reg [`REG_DATA_WIDTH-1:0] memTexUnit[`TU_DEPTH-1:0];
reg [7:0]                 rIndex0, rIndex1;
reg [15:0]                rPC;
reg [`REG_DATA_WIDTH-1:0] memVerAttr[`VA_DEPTH-1:0];
reg [7:0]                 rAddr0, rAddr1;
always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        rEnable0IX0 <= 1'b0;
        rEnable0IX1 <= 1'b0;
        rEnable0TU  <= 1'b0;
        rEnable0GP  <= 1'b0;
        rEnable0Wr  <= 1'b0; 
        rAddr0      <= 8'b0;
        rEnable1IX0 <= 1'b0;
        rEnable1IX1 <= 1'b0;
        rEnable1TU  <= 1'b0;
        rEnable1GP  <= 1'b0;
        rEnable1Wr  <= 1'b0; 
        rAddr1      <= 8'b0;         
    end else begin 
        if (wValid) begin 
            case (wSrc0Reg) 
                8'h00 : begin 
                            rEnable0IX0 <= 1'b1;
                            rEnable0IX1 <= 1'b0;
                            rEnable0TU  <= 1'b0;
                            rEnable0GP  <= 1'b0;
                            rEnable0Wr  <= 1'b0;
                            rAddr0      <= 8'b0;
                        end 
                8'h01 : begin 
                            rEnable0IX0 <= 1'b0; //Read Index0 register
                            rEnable0IX1 <= 1'b1;
                            rEnable0TU  <= 1'b0;
                            rEnable0GP  <= 1'b0;
                            rEnable0Wr  <= 1'b0; 
                            rAddr0      <= 8'b0;
                        end 
                8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h09,
                8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10:
                        begin 
                            rEnable0IX0 <= 1'b0;
                            rEnable0IX1 <= 1'b0;
                            rEnable0TU  <= 1'b1; //Read the Texture Unit
                            rEnable0GP  <= 1'b0;
                            rEnable0Wr  <= 1'b0; 
                            rAddr0      <= wSrc1Reg -8'h2;
                        end 
                default:begin 
                            rEnable0IX0 <= 1'b0;
                            rEnable0IX1 <= 1'b0;
                            rEnable0TU  <= 1'b0;
                            rEnable0GP  <= 1'b1; //Read the General Purpose register
                            rEnable0Wr  <= 1'b0; 
                            rAddr0      <= wSrc1Reg -8'h11;
                        end 
            endcase  
            case (wSrc1Reg) 
                8'h00 : begin 
                            rEnable1IX0 <= 1'b1;
                            rEnable1IX1 <= 1'b0;
                            rEnable1TU  <= 1'b0;
                            rEnable1GP  <= 1'b0;
                            rEnable1Wr  <= 1'b0;
                            rAddr1      <= 1'b0;
                        end 
                8'h01 : begin 
                            rEnable1IX0 <= 1'b0; //Read Index0 register
                            rEnable1IX1 <= 1'b1;
                            rEnable1TU  <= 1'b0;
                            rEnable1GP  <= 1'b0;
                            rEnable1Wr  <= 1'b0; 
                            rAddr1      <= 1'b0;
                        end 
                8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h09,
                8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F,8'h10:
                        begin 
                            rEnable1IX0 <= 1'b0;
                            rEnable1IX1 <= 1'b0;
                            rEnable1TU  <= 1'b1; //Read the Texture Unit
                            rEnable1GP  <= 1'b0;
                            rEnable1Wr  <= 1'b0; 
                            rAddr1      <= wSrc1Reg -8'h2;
                        end 
                default:begin 
                            rEnable1IX0 <= 1'b0;
                            rEnable1IX1 <= 1'b0;
                            rEnable1TU  <= 1'b0;
                            rEnable1GP  <= 1'b1; //Read the General Purpose registers
                            rEnable1Wr  <= 1'b0; 
                            rAddr1      <= wSrc1Reg - 8'h11;
                        end 
            endcase  
        end else begin 
            rEnable0IX0 <= 1'b0;
            rEnable0IX1 <= 1'b0;
            rEnable0TU  <= 1'b0;
            rEnable0GP  <= 1'b0;
            rEnable0Wr  <= 1'b0; 
            rAddr0      <= 8'b0;
            rEnable1IX0 <= 1'b0;
            rEnable1IX1 <= 1'b0;
            rEnable1TU  <= 1'b0;
            rEnable1GP  <= 1'b0;
            rEnable1Wr  <= 1'b0; 
            rAddr1      <= 8'b0;
        end 
    end 
end 

reg [`SHADER_CORE_DATA_WIDTH-1:0] rSrc0RegData;
reg [`SHADER_CORE_DATA_WIDTH-1:0] rSrc1RegData;
always @(posedge clk or negedge resetn) begin 
    if (~resetn) begin 
        rSrc0RegData <= `SHADER_CORE_DATA_WIDTH'h0;
        rSrc1RegData <= `SHADER_CORE_DATA_WIDTH'h0;
    end else begin 
        if (rEnable0IX0) begin 
            rSrc0RegData <= memVerAttr[rIndex0];
        end else if (rEnabel0TU) begin 
            rSrc0RegData <= memTexUnit[rAddr0];
        end else if (rEnabel0GP) begin 
            rSrc0RegData <= memGenPurp[rAddr0];
        end else if (rEnable0IX1) begin 
            rSrc0RegData <= memVerAttr[rIndex1];
        end  
        if (rEnable1IX0) begin 
            rSrc1RegData <= memVerAttr[rIndex0];
        end else if (rEnabel1TU) begin 
            rSrc0RegData <= memTexUnit[rAddr1];
        end else if (rEnable1GP) begin 
            rSrc1RegData <= memGenPurp[rAddr1];
        end else if (rEnable1IX1) begin 
            rSrc1RegData <= memVerAttr[rIndex1];
        end  
    end 

end 
assign oReady       = wValidPP1;
assign oSrc0RegData = rSrc0RegData;
assign oSrc1RegData = rSrc1RegData;

endmodule 
