module test;
    reg clk, rst;
    reg [31:0]input_32;
    mips mips_all(clk, rst, input_32);
    initial
    begin
        clk = 1; rst = 1; 
        #5 rst = 0;
    	$readmemh("lwx1_after.txt", mips_all.im.im, 'h1000);
    	$readmemh("lwx2_after.txt", mips_all.im.im, 'h180);
    end
    
    initial
    begin
	    input_32 = 32'h00001000;
	    #5000 input_32 = 32'h00001111;
    end

    always 
    #30 clk = ~clk;
endmodule
