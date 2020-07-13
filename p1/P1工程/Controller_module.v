module Controller_module(opcode_in, funct_in, RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, nPC_sel, Extop, j_sel, ALUctr, jr_sel, jal_sel, addi_sel);
    input [5:0]opcode_in;
    input [5:0]funct_in;
    output ALUSrc, RegWrite, MemWrite, nPC_sel, j_sel, jr_sel, jal_sel, addi_sel;
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

    wire addu = (opcode_in == addu_opcode && funct_in == addu_funct);
    wire subu = (opcode_in == subu_opcode && funct_in == subu_funct);
    wire ori = opcode_in == ori_opcode;
    wire lw = opcode_in == lw_opcode;
    wire sw = opcode_in == sw_opcode;
    wire beq = opcode_in == beq_opcode;
    wire lui = opcode_in == lui_opcode;
    wire j = opcode_in == j_opcode;
    wire addi = opcode_in == addi_opcode;
    wire addiu = opcode_in == addiu_opcode;
    wire slt = (opcode_in == slt_opcode && funct_in == slt_funct);
    wire jal = opcode_in == jal_opcode;
    wire jr = (opcode_in == jr_opcode && funct_in == jr_funct);
    wire BGEZAL = (opcode_in == 6'b000001);

    assign RegDst[0] = addu || subu || slt;  //
    assign RegDst[1] = jal || BGEZAL;
    assign ALUSrc = ori || lw || sw || lui || addi || addiu;
    assign MemtoReg[0] = lw;
    assign MemtoReg[1] = jal || BGEZAL;   //
    assign RegWrite = addu || subu || ori || lw || lui || addi || addiu || slt || jal || BGEZAL;  //
    assign MemWrite = sw;
    assign nPC_sel = beq || BGEZAL;
    assign j_sel = j;
    assign Extop[0] = lui;
    assign Extop[1] = lw || sw || addi || addiu;
    assign ALUctr[0] = addu || lw || sw || slt || addi || addiu;
    assign ALUctr[1] = subu || beq || slt;
    assign ALUctr[2] = ori;
    assign jr_sel = jr;
    assign jal_sel = jal;
    assign addi_sel = addi;

endmodule
