module GPR_module(clk, reset, reg_write_in, read_reg1_in, read_reg2_in, write_reg_in, write_data_in, read_data1_out, read_data2_out, overflow, tmp);
    input [4:0]read_reg1_in;
    input [4:0]read_reg2_in;
    input [4:0]write_reg_in;
    input [31:0]write_data_in;
    input clk, reset, reg_write_in, overflow;
    output [31:0]read_data1_out;
    output [31:0]read_data2_out;
    output tmp;
    reg [31:0] reg_all[31:0];
    wire [31:0] read_data1_out;
    wire [31:0] read_data2_out;
    wire tmp;
    assign read_data1_out = reg_all[read_reg1_in];
    assign tmp = ($signed(read_data1_out) > 0) ? 1 : 0;
	  assign read_data2_out = reg_all[read_reg2_in];
    always @ (posedge clk or posedge reset)
	  if(reset)
	    begin
	    reg_all[0] <= 32'h0000_0000;
	    reg_all[1] <= 32'h0000_0000;
	    reg_all[2] <= 32'h0000_0000;
	    reg_all[3] <= 32'h0000_0000;
	    reg_all[4] <= 32'h0000_0000;
	    reg_all[5] <= 32'h0000_0000;
	    reg_all[6] <= 32'h0000_0000;
	    reg_all[7] <= 32'h0000_0000;
	    reg_all[8] <= 32'h0000_0000;
	    reg_all[9] <= 32'h0000_0000;
	    reg_all[10] <= 32'h0000_0000;
	    reg_all[11] <= 32'h0000_0000;
	    reg_all[12] <= 32'h0000_0000;
	    reg_all[13] <= 32'h0000_0000;
	    reg_all[14] <= 32'h0000_0000;
	    reg_all[15] <= 32'h0000_0000;
	    reg_all[16] <= 32'h0000_0000;
	    reg_all[17] <= 32'h0000_0000;
	    reg_all[18] <= 32'h0000_0000;
	    reg_all[19] <= 32'h0000_0000;
	    reg_all[20] <= 32'h0000_0000;
	    reg_all[21] <= 32'h0000_0000;
	    reg_all[22] <= 32'h0000_0000;
	    reg_all[23] <= 32'h0000_0000;
	    reg_all[24] <= 32'h0000_0000;
	    reg_all[25] <= 32'h0000_0000;
	    reg_all[26] <= 32'h0000_0000;
	    reg_all[27] <= 32'h0000_0000;
	    reg_all[28] <= 32'h0000_0000;
	    reg_all[29] <= 32'h0000_0000;
	    reg_all[30] <= 32'h0000_0000;
	    reg_all[31] <= 32'h0000_0000;
	    end
	else
	  begin
	    if(reg_write_in && (!overflow) && (write_reg_in[4:0] != 0))
		      reg_all[write_reg_in[4:0]] <= write_data_in;
	    else if(reg_write_in && overflow)
		      reg_all[30][0] <= 1'b1;
		end
endmodule
    
