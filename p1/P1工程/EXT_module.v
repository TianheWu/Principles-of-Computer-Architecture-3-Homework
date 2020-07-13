module EXT_module(imm16_in, imm32_out, EXTop);
    input [15:0]imm16_in;
    input [1:0]EXTop;
    output [31:0]imm32_out;
    reg [31:0]imm32_out;
    always @ (*)
        case(EXTop)
        2'b00: imm32_out = {{16'h0000}, imm16_in};
	      2'b01: imm32_out = {imm16_in, {16'h0000}};
	      2'b10: imm32_out = {{16{imm16_in[15]}}, imm16_in};
	default: imm32_out = 0;
	endcase
endmodule
    