module B_reg_module(clk, read_data2_in, read_data2_out);
    input clk;
    input [31:0]read_data2_in;
    output [31:0]read_data2_out;
    reg [31:0]read_data2_out;
    always @ (posedge clk)
    read_data2_out <= read_data2_in;
endmodule
