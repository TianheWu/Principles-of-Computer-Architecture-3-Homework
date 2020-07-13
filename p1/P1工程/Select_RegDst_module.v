module Select_RegDst_module(din1, din2, dout, RegDst);
    input [4:0]din1, din2;
    input [1:0]RegDst;
    output [4:0]dout;
    reg [4:0]dout;
    always @ (*)
    case(RegDst)
    2'b00: dout = din1;
    2'b01: dout = din2;
    2'b10: dout = 31;
    endcase
endmodule
