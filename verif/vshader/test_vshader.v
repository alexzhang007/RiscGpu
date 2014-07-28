module test;
reg clk;
reg resetn;
reg [127:0] rA, rB;
reg [31:0]  rAX,rAY,rAZ,rAW, rBX, rBY, rBZ, rBW;
reg [5:0]   rOp;
reg         rValid;
wire        wDone;
event start_sim_evt;
event end_sim_evt;

shader_core  GART_GPU(
  .clk(clk),
  .resetn(resetn),
  .iValid(rValid),
  .iA(rA),
  .iB(rB),
  .iALU_Op(rOp),
  .oResult(wResult),
  .oReady(wDone)
);
initial begin 
    basic;
end 
initial begin 
    $fsdbDumpfile("./out/vshader.fsdb");
    $fsdbDumpvars(0, test);
end 
task basic ;
fork
    drive_clock;
    reset_unit;
    drive_sim;
    monitor_sim;
join 
endtask 
task monitor_sim;
   begin 
   @(end_sim_evt);
   #10;
   $display("Test End");
   $finish;
   end 
endtask
task reset_unit;
    begin 
        #5;
        resetn = 1;
        #10;
        resetn = 0;
        rValid = 0;
        rA     = 0;
        rAX    = 0;
        rAY    = 0;
        rAZ    = 0;
        rAW    = 0;
        rB     = 0;
        rBX    = 0;
        rBY    = 0;
        rBZ    = 0;
        rBW    = 0;
        rOp    = 0;
        #10;   //Before Reset is done, the Bit should have its real value
        #20;
        resetn = 1;
        ->start_sim_evt;
        $display("Reset is done");
        end
endtask 
task  drive_clock;
    begin 
        clk = 0;
        forever begin 
        #5 clk = ~clk;
        end 
    end 
endtask
task  drive_sim;
    @(start_sim_evt);
    @(posedge clk);
    rAX <= 32'hABCD;
    rAY <= 32'h1234;
    rAZ <= 32'h2345;
    rAW <= 32'h3456;
    rBX <= 32'hBCDA;
    rBY <= 32'h2341;
    rBZ <= 32'h3452;
    rBW <= 32'h4563;
    @(posedge clk);
    rValid <= 1'b1;
    rOp    <= `OP_DP4; //Add is 01
    rAX    <= 0;
    rAY    <= 0;
    rAZ    <= 0;
    rAW    <= 0;
    rBX    <= 0;
    rBY    <= 0;
    rBZ    <= 0;
    rBW    <= 0;
    rA  <= {rAX, rAY, rAZ, rAW};
    rB  <= {rBX, rBY, rBZ, rBW};
    @(posedge clk);
    rValid <= 1'b0;
    rOp    <= 0;
    rValid <= 1'b0;
    rA  <= {rAX, rAY, rAZ, rAW};
    rB  <= {rBX, rBY, rBZ, rBW};
    repeat (100) @(posedge clk);
    ->end_sim_evt;
endtask 

endmodule 
    
