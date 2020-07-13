module Select_ALUSrc_module(din1, din2, dout, ALUSrc);
    input [31:0]din1, din2;
    input ALUSrc;
    output [31:0]dout;
    reg [31:0]dout;
    always @ (*)
    case(ALUSrc)
    1'b0: dout = din1;
    1'b1: dout = din2;
    endcase
endmodule