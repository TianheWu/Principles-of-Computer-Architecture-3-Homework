module Controller_module(clk, reset, zero, opcode_in, funct_in, RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, 
                         nPC_sel, Extop, j_sel, ALUctr, jr_sel, jal_sel, addi_sel, PCWr, IRWr, LB_sel, sb_sel, tmo, bltzal_sel);
    input clk, reset, zero;
    input [5:0]opcode_in;
    input [5:0]funct_in;
    input [4:0]tmo;
    parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
    reg [3:0]current_state, next_state;
    output ALUSrc, RegWrite, MemWrite, nPC_sel, j_sel, jr_sel, jal_sel, addi_sel, PCWr, IRWr, LB_sel, sb_sel, bltzal_sel;
    output [1:0]RegDst, MemtoReg, Extop;
    output [2:0]ALUctr;
  
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
  
    assign RegDst[0] = addu || subu || slt;  
    assign RegDst[1] = jal || bltzal;
    assign ALUSrc = ori || lw || sw || lui || addi || addiu || lb || sb;
    assign MemtoReg[0] = lw || lb;
    assign MemtoReg[1] = jal || bltzal;   
    assign RegWrite = (current_state == S4 && (addu || subu || ori || lw || lui || addi || addiu || slt || jal || lb || bltzal));  
    assign MemWrite = (current_state == S3 && (sw || sb));
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
            (current_state === S2 && j_sel) ? 1 : (current_state === S4 && bltzal) ? 1 : 0;  //
    assign IRWr = current_state === S0 ? 1 : 0;
        
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
        S2: if(addu||subu||ori||lui||addi||addiu||slt)
                next_state = S4;
            else if(j||jr||beq) next_state = S0;           // 
            else if(sw||sb||lw||lb) next_state = S3;
            else next_state = S0;
        S3: if(sw||sb) next_state = S0;
            else if(lw||lb) next_state = S4;
            else next_state = S0; 
        S4: next_state = S0;
        endcase

endmodule
