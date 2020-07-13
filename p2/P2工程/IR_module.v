module IR_module(clk, im_in, IRWr, ir_out);
    input clk, IRWr;
    input [31:0]im_in;
    output [31:0]ir_out;
    reg [31:0]ir_out;
    
    always @ (posedge clk)
    if(IRWr)
      ir_out <= im_in;
    else ir_out <= ir_out;
endmodule
  