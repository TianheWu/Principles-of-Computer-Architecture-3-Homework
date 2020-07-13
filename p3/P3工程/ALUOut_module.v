module ALUOut_module(clk, ALUOut_in, ALUOut_out);
    input clk;
    input [31:0]ALUOut_in;
    output [31:0]ALUOut_out;
    reg [31:0]ALUOut_out;
    always @ (clk)
    ALUOut_out <= ALUOut_in;
endmodule
