module ALU_module(busA_in, busB_in, ALUctr, ALU_out, zero, overflow, addi_sel);
    input [31:0]busA_in;
    input [31:0]busB_in;
    input [2:0]ALUctr;
    input addi_sel;
    output [31:0]ALU_out;
    output zero, overflow;
    reg [31:0]ALU_out;
    reg [31:0]tmp;
    reg overflow;
    reg slt_sel;
    assign zero = (busA_in - busB_in) === 0 ? 1 : 0;
    always @ (*)
        case(ALUctr)
        3'b000: begin
                ALU_out = busB_in;                     // lui
                overflow = 0;
                end
        3'b001: 
	             begin
	             tmp = busA_in + busB_in;
	             if(((busA_in[31] == 1'b0 && busB_in[31] == 1'b0 && tmp[31] == 1'b1)||(busA_in[31] == 1'b1 
	                  && busB_in[31] == 1'b1 && tmp[31] == 1'b0)) && addi_sel)
		           overflow = 1; 
	             else overflow = 0;
               ALU_out = busA_in + busB_in;              // addu, addi, addiu, lw, sw
	             end
	         
        3'b010: begin
                ALU_out = busA_in - busB_in;    
                overflow = 0;  
                end    // subu, beq
	      3'b011: begin
	         if($signed(busA_in) < $signed(busB_in))
		          ALU_out = 1;                          // slt
	       	 else ALU_out = 0;
	       	 overflow = 0;
	       	 end
        3'b100: begin
           ALU_out = busA_in | busB_in;          // ori
           overflow = 0;
           end
           default: begin
           ALU_out = 0;
           overflow = 0;
           end
       endcase
endmodule
