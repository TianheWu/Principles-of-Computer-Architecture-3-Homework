module mips(clk, rst, input_32);
    input clk, rst;
    input [31:0]input_32;

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

    wire [1:0]RegDst_MUX;
    wire [2:0]MemtoReg;
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
    wire Output_Device_we_from_bridge, TC_we_from_bridge;
    wire IRQ_wire, IRQ_NPC_Controller, IRQ_tc_cp0;
    wire ERET_sel_NPC_Controller;
    wire EXLSet_wire, EXLClr_wire;
    wire [31:0]DEV_WD;
    wire [31:0]DEV_tc_to_bridge, DEV_output_device_to_bridge, DEV_input_device_to_bridge;
    wire [1:0]DEV_Addr;
    wire We_CPU_Controller_bridge;
    wire [31:0]CP0_Dout, PrRD_5_1;
    wire CP0_Wr_Controller_to_cp0, CP0_Dst_Controller_to_cp0;
    wire [3:0]current_state_wire;
    wire [31:2]EPC_wire;

    
    im_1k im(.addr(pc_to_im_npc[12:0]), .dout(dout_im_to_gpr));         // im
    IR_module ir(.clk(clk), .im_in(dout_im_to_gpr), .IRWr(irwr_controller_to_ir), .ir_out(ir_out_ir_to_gpr));

    PC_module pc(.npc_in(npc_to_pc), .clk(clk), .reset(rst), .pc_out(pc_to_im_npc), .PCWr(pcwr_controller_to_pc));                         // pc

    NPC_module npc(.pc_in(pc_to_im_npc), .npc_out(npc_to_pc), .imm_in(ir_out_ir_to_gpr[15:0]), .pc4_out(pc4_to_MemtoReg_MUX), 
                   .npc_sel(npc_sel_controller_to_npc), .zero(zero_alu_to_npc), .j_sel(j_sel_controller_to_npc), 
                   .j26_in(ir_out_ir_to_gpr[25:0]), .jr_sel(jr_sel_controller_to_npc), .jr_val(a_out_to_npc_alu), // attention jr
                   .jal_sel(jal_sel_controller_to_npc), .tmp(tmppp), .bltzal_sel(bltzal_sel), .ERET_in(EPC_wire[31:2]), 
                   .IntReq(IRQ_NPC_Controller), .ERET_sel(ERET_sel_NPC_Controller), .current_sel(current_state_wire));   // npc
                   
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
    
    dm_1k dm(.clk(clk), .we(we_MemWrite_controller_to_dm), .addr(aluout_to_dm_memtoreg_MUX[15:0]), 
             .din(sb_out_to_dm), .dout(dout_dm_MemtoReg_MUX));                            // dm

    DR_module dr(.clk(clk), .dm_in(lb_to_selectlb), .dr_out(dr_out_to_dr_reg));
    
    LB_module lb(.dm_in(dout_dm_MemtoReg_MUX), .LB_out(lb_to_selectlb), .LB_sel(lb_sel));
    
    EXT_module ext(.imm16_in(ir_out_ir_to_gpr[15:0]), .imm32_out(imm32_out_to_ALUSrc_MUX), .EXTop(EXTop_controller_to_ext));       // ext
    
    Controller_module controller(.clk(clk), .reset(rst), .zero(zero_alu_to_npc), .opcode_in(ir_out_ir_to_gpr[31:26]), 
                                 .funct_in(ir_out_ir_to_gpr[5:0]), .RegDst(RegDst_MUX), 
                                 .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(reg_write_in_controller_to_gpr), 
                                 .MemWrite(we_MemWrite_controller_to_dm), .nPC_sel(npc_sel_controller_to_npc), 
                                 .Extop(EXTop_controller_to_ext), .j_sel(j_sel_controller_to_npc), .ALUctr(ALUctr_controller_to_alu), 
                                 .jr_sel(jr_sel_controller_to_npc), .jal_sel(jal_sel_controller_to_npc), 
                                 .addi_sel(addi_sel_controller_to_alu), .PCWr(pcwr_controller_to_pc), 
                                 .IRWr(irwr_controller_to_ir), .LB_sel(lb_sel), .sb_sel(sb_sel), .tmo(ir_out_ir_to_gpr[20:16]), 
                                 .bltzal_sel(bltzal_sel), .MTFC0_rs(ir_out_ir_to_gpr[25:21]), .IntReq(IRQ_wire), .EXLSet(EXLSet_wire),
                                 .EXLClr(EXLClr_wire), .CP0_Wr(CP0_Wr_Controller_to_cp0), .CP0_Dst(CP0_Dst_Controller_to_cp0),
                                 .DEV_Wr(We_CPU_Controller_bridge), .ALUOut_DEV(aluout_to_dm_memtoreg_MUX), .IntReq_out(IRQ_NPC_Controller), 
                                 .ERET_sel(ERET_sel_NPC_Controller), .current_state(current_state_wire));  // controller
    
    Select_MemtoReg_module select_MemtoReg(.ALU_out(aluout_to_dm_memtoreg_MUX), .DM_out(dr_out_to_dr_reg), .pc4_out(pc4_to_MemtoReg_MUX), 
                                  .MemtoReg(MemtoReg), .select_out(write_data_in), .MFC0_in(CP0_Dout), .bridge_in(PrRD_5_1));

    Select_RegDst_module select_RegDst(.din1(ir_out_ir_to_gpr[20:16]), .din2(ir_out_ir_to_gpr[15:11]), 
                                       .dout(write_reg_in), .RegDst(RegDst_MUX));
    
    Select_ALUSrc_module select_ALUSrc(.din1(b_out_to_alu), .din2(imm32_out_to_ALUSrc_MUX), .dout(busB_in), .ALUSrc(ALUSrc));
    
    wire [4:0]cp0_sel2; 
    
    CP0_module cp0(.clk(clk), .rst(rst), .pc_out_in(pc_to_im_npc[31:2]), .DIn(b_out_to_alu), .HWInt({5'b00000, IRQ_tc_cp0}), 
                   .Sel(cp0_sel2), .Wen(CP0_Wr_Controller_to_cp0), 
                   .EXLSet(EXLSet_wire), .EXLClr(EXLClr_wire), .IntReq(IRQ_wire), .EPC(EPC_wire[31:2]), .DOut(CP0_Dout)); // CP0 IRQ to Controller
                                    
    assign cp0_sel2 = CP0_Dst_Controller_to_cp0 ? 5'd14 : ir_out_ir_to_gpr[15:11];   
                
    
    
    TC_module tc(.clk(clk), .rst(rst), .we(TC_we_from_bridge), .ADDr_in(DEV_Addr), .Data_in(DEV_WD), 
                 .Data_out(DEV_tc_to_bridge), .IRQ(IRQ_tc_cp0));
    
    Bridge_module bridge(.We_CPU(We_CPU_Controller_bridge), .PrAddr(aluout_to_dm_memtoreg_MUX), .PrWD(b_out_to_alu), 
                         .DEV_Addr(DEV_Addr), .DEV_WD(DEV_WD), 
                         .PrRD(PrRD_5_1), .DEV1_RD(DEV_tc_to_bridge), 
                         .DEV2_RD(DEV_output_device_to_bridge), .DEV3_RD(DEV_input_device_to_bridge),
                         .Output_Device_we(Output_Device_we_from_bridge), .TC_we(TC_we_from_bridge)); // DEV_WD_to_3 device Din
    
    Input_Device_module input_device(.Data_in(input_32), .Data_out(DEV_input_device_to_bridge));
    
    Output_Device_module output_device(.clk(clk), .rst(rst), .Data_in(DEV_WD), .Data_out(DEV_output_device_to_bridge), 
                                       .sel_signal(DEV_Addr[0]), .we(Output_Device_we_from_bridge));
    
    
    

endmodule
