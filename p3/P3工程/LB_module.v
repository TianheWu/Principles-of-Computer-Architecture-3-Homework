module LB_module(dm_in, LB_out, LB_sel);
    input [31:0]dm_in;
    input LB_sel;
    output [31:0]LB_out;
    reg [31:0]LB_out;
    
    always @ (*)
        if(LB_sel)
          begin
            LB_out[31:8] = (dm_in[7] == 1) ? 24'hffffff : 24'h000000;
            LB_out[7:0] = dm_in[7:0];
          end
        else LB_out = dm_in; 
endmodule
