module im_1k(addr, dout);
    input [12:0]addr;
    output [31:0]dout;
    reg [7:0] im[8192:0];
    assign dout = {im[addr[12:0]], im[addr[12:0] + 1], im[addr[12:0] + 2], im[addr[12:0] + 3]};
endmodule
