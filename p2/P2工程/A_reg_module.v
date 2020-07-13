module A_reg_module(clk, read_data1_in, read_data1_out);
    input clk;
    input [31:0]read_data1_in;
    output [31:0]read_data1_out;
    reg [31:0]read_data1_out;
    always @ (posedge clk)
    read_data1_out <= read_data1_in;
endmodule
