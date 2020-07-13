module PC_module(npc_in, clk, reset, pc_out);	
    input [31:0]npc_in;
    input clk, reset;
    output [31:0]pc_out;
    reg [31:0]pc_out;
    always @ (posedge clk or posedge reset)
    	if(reset)
	       pc_out <= 32'h0000_3000;
	   else pc_out <= npc_in;
endmodule
