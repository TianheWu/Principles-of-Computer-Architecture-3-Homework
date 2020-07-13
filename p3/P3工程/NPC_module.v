module NPC_module(pc_in, npc_out, imm_in, pc4_out, npc_sel, zero, j_sel, j26_in, jr_sel, jr_val, jal_sel, tmp, bltzal_sel, ERET_in, IntReq, ERET_sel, current_sel);
    input [31:0]pc_in;
    input [15:0]imm_in;
    input [25:0]j26_in;
    input [31:0]jr_val;
    input [31:2]ERET_in;
    input [3:0]current_sel;
    input npc_sel, zero, j_sel, jr_sel, jal_sel, tmp, bltzal_sel, IntReq, ERET_sel;
    
    
    output [31:0]npc_out;
    output [31:0]pc4_out;
    wire [31:0]imm_out_wire, imm_ext_wire, imm_sel2_wire;
    wire [31:0]j_sel3_wire;
    wire [2:0]MUX_sel;
    
    assign imm_out_wire = {{16{imm_in[15]}}, imm_in}; 
    assign imm_ext_wire = imm_out_wire << 2; 
    assign imm_sel2_wire = imm_ext_wire + pc_in; 
    assign j_sel3_wire = {pc_in[31:28], j26_in[25:0], {2'b00}}; 
    
    assign MUX_sel[0] = ((npc_sel & zero) | (tmp & bltzal_sel))|(IntReq) ? 1 : 0;     //
    assign MUX_sel[1] = (j_sel | jal_sel) && (!IntReq) ? 1 : 0;
    assign MUX_sel[2] = (ERET_sel)|(IntReq) ? 1 : 0;

    assign pc4_out = pc_in; 
    reg [31:0]npc_out_pre;
    reg [31:0]npc_out;
    always @ (*)
	case(MUX_sel)
	3'b000: npc_out_pre = pc_in + 4;
	3'b001: npc_out_pre = imm_sel2_wire;
	3'b010: npc_out_pre = j_sel3_wire;
	3'b100: npc_out_pre = {ERET_in, 2'b00};
	3'b101: npc_out_pre = 32'h00004180;
	default: npc_out_pre = 32'h0000_3000;
	endcase
	
    always @ (*)                            // choose jr
	case(jr_sel)
	1'b0: npc_out = npc_out_pre;
	1'b1: npc_out = jr_val;
	endcase
endmodule
