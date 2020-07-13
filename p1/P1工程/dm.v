module dm_1k(clk, we, addr, din, dout);
    input [9:0]addr;
    input [31:0]din;
    input clk, we;
    output [31:0]dout;
    reg [7:0] dm[1023:0];
    assign dout = {dm[addr[9:0] + 3], dm[addr[9:0] + 2], dm[addr[9:0] + 1], dm[addr[9:0]]};
    always @ (posedge clk)       
      if(we)
	    begin
	    dm[addr[9:0] + 3] <= din[31:24];
	    dm[addr[9:0] + 2] <= din[23:16];
	    dm[addr[9:0] + 1] <= din[15:8];
	    dm[addr[9:0]] <= din[7:0];
	    end
endmodule