module SB_module(dm_in, B_reg_in, sb_sel, sb_out);
    input [31:0]dm_in;
    input [31:0]B_reg_in;
    input sb_sel;
    output [31:0]sb_out;
    wire [31:0]sb_val;
    assign sb_val = {dm_in[31:8], B_reg_in[7:0]};
    assign sb_out = sb_sel == 1 ? sb_val : B_reg_in;
endmodule
