module Controller_module(clk, reset, zero, opcode_in, funct_in, RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, 
                         nPC_sel, Extop, j_sel, ALUctr, jr_sel, jal_sel, addi_sel, PCWr, IRWr, LB_sel, sb_sel, 
                         tmo, bltzal_sel, MTFC0_rs, IntReq, EXLSet, EXLClr, CP0_Wr, CP0_Dst, DEV_Wr, ALUOut_DEV, 
                         IntReq_out, ERET_sel, current_state);
                         
    input clk, reset, zero, IntReq;
    input [5:0]opcode_in;
    input [5:0]funct_in;
    input [4:0]tmo;
    input [4:0]MTFC0_rs;
    input [31:0]ALUOut_DEV;
    
    output [3:0]current_state;
    parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5;
    reg [3:0]current_state, next_state;
    output ALUSrc, RegWrite, MemWrite, nPC_sel, j_sel, jr_sel, jal_sel, addi_sel, PCWr, IRWr, LB_sel, sb_sel, bltzal_sel;
    output [1:0]RegDst, Extop;
    output [2:0]ALUctr;
    output [2:0]MemtoReg;
    
    output EXLSet, EXLClr, CP0_Wr, CP0_Dst, DEV_Wr, IntReq_out, ERET_sel;
    
    wire [5:0]addu_opcode = 6'b000000, addu_funct = 6'b100001;
    wire [5:0]subu_opcode = 6'b000000, subu_funct = 6'b100011;
    wire [5:0]ori_opcode = 6'b001101;
    wire [5:0]lw_opcode = 6'b100011;
    wire [5:0]sw_opcode = 6'b101011;
    wire [5:0]beq_opcode = 6'b000100;
    wire [5:0]lui_opcode = 6'b001111;
    wire [5:0]j_opcode = 6'b000010;

    wire [5:0]addi_opcode = 6'b001000;   // addi
    wire [5:0]addiu_opcode = 6'b001001;  // addiu
    wire [5:0]slt_opcode = 6'b000000;    // slt
    wire [5:0]slt_funct = 6'b101010;
    wire [5:0]jal_opcode = 6'b000011;    // jal
    wire [5:0]jr_opcode = 6'b000000;     // jr
    wire [5:0]jr_funct = 6'b001000;
    wire [5:0]LB_opcode = 6'b100000;
    wire [5:0]SB_opcode = 6'b101000;
    wire [5:0]bltzal_opcode = 6'b000001;
    wire [4:0]bltzal_tmp = 6'b10000;
    wire [5:0]MTC0_opcode = 6'b010000;
    wire [5:0]MFC0_opcode = 6'b010000;
    wire [4:0]MTC0_rs = 5'b00100;
    wire [4:0]MFC0_rs = 5'b00000;
    wire [5:0]ERET_opcode = 6'b010000;
    wire [5:0]ERET_funct = 6'b011000;
    
    
    wire addu = (opcode_in === addu_opcode && funct_in === addu_funct);
    wire subu = (opcode_in === subu_opcode && funct_in === subu_funct);
    wire ori = opcode_in === ori_opcode;
    wire lw = opcode_in === lw_opcode;
    wire sw = opcode_in === sw_opcode;
    wire beq = opcode_in === beq_opcode;
    wire lui = opcode_in === lui_opcode;
    wire j = opcode_in === j_opcode;
    wire addi = opcode_in === addi_opcode;
    wire addiu = opcode_in === addiu_opcode;
    wire slt = (opcode_in === slt_opcode && funct_in === slt_funct);
    wire jal = opcode_in === jal_opcode;
    wire jr = (opcode_in === jr_opcode && funct_in === jr_funct);
    wire bltzal = (opcode_in === bltzal_opcode && tmo === bltzal_tmp);
    wire lb = opcode_in === LB_opcode;
    wire sb = opcode_in === SB_opcode;
    wire MFC0 = (opcode_in === MFC0_opcode && MTFC0_rs === MFC0_rs);
    wire MTC0 = (opcode_in === MTC0_opcode && MTFC0_rs === MTC0_rs);
    wire ERET = (opcode_in === ERET_opcode && funct_in === ERET_funct);
    
    
    assign RegDst[0] = addu || subu || slt;  
    assign RegDst[1] = jal || bltzal;
    assign ALUSrc = ori || lw || sw || lui || addi || addiu || lb || sb;
    assign MemtoReg[0] = lw || lb || ((ALUOut_DEV >= 32'h00007f00 && ALUOut_DEV <= 32'h00007f20) && (lw || lb));
    assign MemtoReg[1] = jal || bltzal;
    assign MemtoReg[2] = MFC0 || ((ALUOut_DEV >= 32'h00007f00 && ALUOut_DEV <= 32'h00007f20) && (lw || lb));
    
    
    assign RegWrite = (current_state == S4 && (addu || subu || ori || lw || lui || addi || addiu || slt || jal || lb || bltzal));  
    assign MemWrite = (current_state == S3 && (sw || sb) && (!(ALUOut_DEV >= 32'h00007f00 && ALUOut_DEV <= 32'h00007f20)));
    assign nPC_sel = (current_state != S0 && beq);
    assign j_sel = (current_state != S0 && j);
    assign Extop[0] = lui;
    assign Extop[1] = lw || sw || addi || addiu || lb || sb;
    assign ALUctr[0] = addu || lw || sw || slt || addi || addiu || lb || sb;
    assign ALUctr[1] = subu || beq || slt;
    assign ALUctr[2] = ori;
    assign jr_sel = (current_state != S0 && jr);
    assign jal_sel = (current_state != S0 && jal);
    assign addi_sel = addi;
    assign LB_sel = lb;
    assign sb_sel = sb;
    assign bltzal_sel = (current_state != S0 && bltzal);
    assign PCWr = current_state === S0 ? 1 : (current_state === S2 && zero == 1 && beq) ? 1 : 
                 (current_state === S2 && jr_sel) ? 1 : (current_state === S4 && jal_sel) ? 1 :
                 (current_state === S2 && j_sel) ? 1 : (current_state === S4 && bltzal) ? 1 : 
                 (current_state === S2 & ERET) ? 1 : (current_state === S5) ? 1 : 0;  //
                 
    assign IRWr = current_state === S0 ? 1 : 0;
    assign ERET_sel = (current_state != S0 && ERET);
    assign IntReq_out = (IntReq & (current_state == S5));
    
    
    // EXLSet, EXLClr, CP0_Wr, CP0_Dst, DEV_Wr;
    assign EXLSet = (current_state === S5);
    assign EXLClr = (current_state === S2) & ERET;
    assign CP0_Wr = ((current_state === S2) & MTC0)|(current_state === S5);
    assign CP0_Dst = (current_state === S5); // 0 choose rd, 1 choose 14 reg
    assign DEV_Wr = (ALUOut_DEV >= 32'h00007f00 && ALUOut_DEV <= 32'h00007f20) && (current_state == S3) && (sw || sb);
     
    always @ (posedge clk or posedge reset)
        if(reset) current_state <= S0;
        else current_state <= next_state;   
    
    always @ (*)
        case(current_state)
        S0: next_state = S1;
        S1: 
        begin 
        if(jal || bltzal) 
            next_state = S4;  
        else next_state = S2; 
        end 
        S2: begin
            if(addu||subu||ori||lui||addi||addiu||slt||MFC0)
                next_state = S4;
            else if(j||jr||beq||ERET)
              begin 
                if(IntReq)
                  next_state = S5;
                else next_state = S0;
              end
            else if(sw||sb||lw||lb) next_state = S3;
            else 
              begin
                if(IntReq)
                  next_state = S5;
                else next_state = S0;
              end
            end
        S3: if(sw||sb) 
              begin
                if(IntReq)
                  next_state = S5;
                else next_state = S0;
              end
            else if(lw||lb) next_state = S4;
            else 
              begin
                if(IntReq)
                  next_state = S5;
                else next_state = S0; 
              end
        S4: 
          begin
            if(IntReq)
              next_state = S5;
            else next_state = S0;
          end
        S5: next_state = S0;
        endcase

endmodule
