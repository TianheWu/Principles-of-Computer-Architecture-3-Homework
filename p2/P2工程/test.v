module test;
    reg clk, rst;
    mips mips_all(clk, rst);
    initial
    begin
        clk = 1; rst = 1;
        #5 rst = 0;
    	$readmemh("p2-test.txt", mips_all.im.im);
    end

    always 
    #30 clk = ~clk;
endmodule
