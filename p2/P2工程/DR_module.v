module DR_module(clk, dm_in, dr_out);
    input clk;
    input [31:0]dm_in;
    output [31:0]dr_out;
    reg [31:0]dr_out;
    always @ (posedge clk)
    dr_out <= dm_in;
endmodule