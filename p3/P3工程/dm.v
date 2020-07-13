module dm_1k(clk, we, addr, din, dout);
    input [15:0]addr;
    input [31:0]din;
    input clk, we;
    output [31:0]dout;
    reg [7:0] dm[12287:0];
    assign dout = {dm[addr[15:0] + 3], dm[addr[15:0] + 2], dm[addr[15:0] + 1], dm[addr[15:0]]};
    integer i;
    
    initial
    begin
    for(i = 0; i < 12287; i = i + 1) 
	     dm[i] <= 0;
    end
    
    always @ (posedge clk)       
      if(we)
	    begin
	    dm[addr[15:0] + 3] <= din[31:24];
	    dm[addr[15:0] + 2] <= din[23:16];
	    dm[addr[15:0] + 1] <= din[15:8];
	    dm[addr[15:0]] <= din[7:0];
	    end
endmodule
