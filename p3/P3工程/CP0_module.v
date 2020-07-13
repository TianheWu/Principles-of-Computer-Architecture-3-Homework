module CP0_module(clk, rst, pc_out_in, DIn, HWInt, Sel, Wen, EXLSet, EXLClr, IntReq, EPC, DOut);
    input [31:2]pc_out_in;
    input [31:0]DIn;
    input [5:0]HWInt;
    input [4:0]Sel;
    input clk, rst, Wen, EXLSet, EXLClr;
    output [31:2]EPC;
    output [31:0]DOut;
    output IntReq;
    reg [15:10]im;   // SR
    reg exl, ie;
    reg [15:10]hwint_pend;  // Cause
    reg [31:2]EPC;
    reg [7:2]IM;
    reg [31:0]PRID;
    assign IntReq = |(hwint_pend & im[15:10]) & ie & !exl;
    assign DOut = (Sel == 12) ? {16'h0000, im, 8'h00, exl, ie} :
                  (Sel == 13) ? {16'h0000, hwint_pend, 10'b0000000000} :
                  (Sel == 14) ? {EPC, 2'b00} :
                  (Sel == 15) ? PRID : 32'h00000000;
    always @ (posedge clk or posedge rst)
        if(rst)
            begin
            im <= 16'h0000;
            exl <= 1'b0;
            ie <= 1'b0;
            hwint_pend <= 6'b000000;
            EPC <= 32'h00000000;
            PRID <= 32'h00000000;
            end
        else
            begin
            if(EXLClr)
                exl <= 1'b0;
            if(EXLSet)
                exl <= 1'b1;
            if(HWInt != 0)          
                hwint_pend <= HWInt;
            if(Wen)
                case(Sel)
                12: {im, exl, ie} <= {DIn[15:0], DIn[1], DIn[0]};
                13: hwint_pend <= DIn[15:10];
                14: EPC <= pc_out_in;
                15: PRID <= DIn;
                endcase
            end
endmodule