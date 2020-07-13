module mips(clk, rst);
    input clk, rst;

    wire clk, rst;        // clk_wire

    wire [31:0]dout_im_to_gpr;
    wire [31:0]npc_to_pc, pc_to_im_npc;   // pc_in, npc_out

    wire [4:0]write_reg_in; // !!!!!!!!!!!!!!
    wire [31:0]write_data_in, read_data1_out_to_alu_npc, read_data2_out_to_alu;
    wire reg_write_in_controller_to_gpr, overflow_alu_to_gpr;                     // overflow_wire

    wire [31:0]pc4_to_MemtoReg_MUX;
    wire npc_sel_controller_to_npc, zero_alu_to_npc, j_sel_controller_to_npc, jr_sel_controller_to_npc;

    wire [31:0]busB_in, ALU_out_to_dm_MemtoReg_MUX;     // busB!!!!!!!!!!!
    wire [2:0]ALUctr_controller_to_alu;

    wire [31:0]dout_dm_MemtoReg_MUX;
    wire we_MemWrite_controller_to_dm;         // din = busB_in

    wire [31:0]imm32_out_to_ALUSrc_MUX;
    wire [1:0]EXTop_controller_to_ext;

    wire [1:0]RegDst_MUX, MemtoReg;
    wire ALUSrc, addi_sel_controller_to_alu;
    wire jal_sel_controller_to_npc;
    
    wire pcwr_controller_to_pc, irwr_controller_to_ir, lb_sel, sb_sel;
    wire [31:0]ir_out_ir_to_gpr;
    wire [31:0]a_out_to_npc_alu, b_out_to_alu;
    wire [31:0]aluout_to_dm_memtoreg_MUX;
    wire [31:0]dr_out_to_dr_reg;
    wire [31:0]lb_to_selectlb;
    wire [31:0]sb_out_to_dm;
    wire tmppp, bltzal_sel;


    im_1k im(.addr(pc_to_im_npc[9:0]), .dout(dout_im_to_gpr));         // im
    IR_module ir(.clk(clk), .im_in(dout_im_to_gpr), .IRWr(irwr_controller_to_ir), .ir_out(ir_out_ir_to_gpr));

    PC_module pc(.npc_in(npc_to_pc), .clk(clk), .reset(rst), .pc_out(pc_to_im_npc), .PCWr(pcwr_controller_to_pc));                         // pc

    NPC_module npc(.pc_in(pc_to_im_npc), .npc_out(npc_to_pc), .imm_in(ir_out_ir_to_gpr[15:0]), .pc4_out(pc4_to_MemtoReg_MUX), 
                   .npc_sel(npc_sel_controller_to_npc), .zero(zero_alu_to_npc), .j_sel(j_sel_controller_to_npc), 
                   .j26_in(ir_out_ir_to_gpr[25:0]), .jr_sel(jr_sel_controller_to_npc), .jr_val(a_out_to_npc_alu), // attention jr
                   .jal_sel(jal_sel_controller_to_npc), .tmp(tmppp), .bltzal_sel(bltzal_sel));   // npc
                   
    A_reg_module a(.clk(clk), .read_data1_in(read_data1_out_to_alu_npc), .read_data1_out(a_out_to_npc_alu));
    
    B_reg_module b(.clk(clk), .read_data2_in(read_data2_out_to_alu), .read_data2_out(b_out_to_alu));
    
    SB_module sb(.dm_in(dout_dm_MemtoReg_MUX), .B_reg_in(b_out_to_alu), .sb_sel(sb_sel), .sb_out(sb_out_to_dm));
    
    GPR_module gpr(.clk(clk), .reset(rst), .reg_write_in(reg_write_in_controller_to_gpr), .read_reg1_in(ir_out_ir_to_gpr[25:21]), 
                   .read_reg2_in(ir_out_ir_to_gpr[20:16]), .write_reg_in(write_reg_in), .write_data_in(write_data_in), 
                   .read_data1_out(read_data1_out_to_alu_npc), .read_data2_out(read_data2_out_to_alu), 
                   .overflow(overflow_alu_to_gpr), .tmp(tmppp));   // gpr
    
    ALU_module alu(.busA_in(a_out_to_npc_alu), .busB_in(busB_in), .ALUctr(ALUctr_controller_to_alu), 
                   .ALU_out(ALU_out_to_dm_MemtoReg_MUX), .zero(zero_alu_to_npc), 
                   .overflow(overflow_alu_to_gpr), .addi_sel(addi_sel_controller_to_alu));       // alu
    
    ALUOut_module aluout(.clk(clk), .ALUOut_in(ALU_out_to_dm_MemtoReg_MUX), .ALUOut_out(aluout_to_dm_memtoreg_MUX));
    
    dm_1k dm(.clk(clk), .we(we_MemWrite_controller_to_dm), .addr(aluout_to_dm_memtoreg_MUX[9:0]), 
             .din(sb_out_to_dm), .dout(dout_dm_MemtoReg_MUX));                            // dm

    DR_module dr(.clk(clk), .dm_in(lb_to_selectlb), .dr_out(dr_out_to_dr_reg));
    
    LB_module lb(.dm_in(dout_dm_MemtoReg_MUX), .LB_out(lb_to_selectlb), .LB_sel(lb_sel));
    
    EXT_module ext(.imm16_in(ir_out_ir_to_gpr[15:0]), .imm32_out(imm32_out_to_ALUSrc_MUX), .EXTop(EXTop_controller_to_ext));       // ext
    
    Controller_module controller(.clk(clk), .reset(rst), .zero(zero_alu_to_npc), .opcode_in(ir_out_ir_to_gpr[31:26]), .funct_in(ir_out_ir_to_gpr[5:0]), .RegDst(RegDst_MUX), 
                                 .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(reg_write_in_controller_to_gpr), 
                                 .MemWrite(we_MemWrite_controller_to_dm), .nPC_sel(npc_sel_controller_to_npc), 
                                 .Extop(EXTop_controller_to_ext), .j_sel(j_sel_controller_to_npc), .ALUctr(ALUctr_controller_to_alu), 
                                 .jr_sel(jr_sel_controller_to_npc), .jal_sel(jal_sel_controller_to_npc), 
                                 .addi_sel(addi_sel_controller_to_alu), .PCWr(pcwr_controller_to_pc), 
                                 .IRWr(irwr_controller_to_ir), .LB_sel(lb_sel), .sb_sel(sb_sel), .tmo(ir_out_ir_to_gpr[20:16]), .bltzal_sel(bltzal_sel));  // controller
    
    Select_MemtoReg_module select_MemtoReg(.ALU_out(aluout_to_dm_memtoreg_MUX), .DM_out(dr_out_to_dr_reg), .pc4_out(pc4_to_MemtoReg_MUX), 
                                  .MemtoReg(MemtoReg), .select_out(write_data_in));

    Select_RegDst_module select_RegDst(.din1(ir_out_ir_to_gpr[20:16]), .din2(ir_out_ir_to_gpr[15:11]), .dout(write_reg_in), .RegDst(RegDst_MUX));
    
    Select_ALUSrc_module select_ALUSrc(.din1(b_out_to_alu), .din2(imm32_out_to_ALUSrc_MUX), .dout(busB_in), .ALUSrc(ALUSrc));
    

endmodule
