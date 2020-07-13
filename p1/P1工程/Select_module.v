module Select_MemtoReg_module(ALU_out, DM_out, pc4_out, MemtoReg, select_out);
    input [31:0]ALU_out, DM_out, pc4_out;
    input [1:0]MemtoReg;
    output [31:0]select_out;
    reg [31:0]select_out;
    always @ (*)
    case(MemtoReg)
    2'b00: select_out = ALU_out;
    2'b01: select_out = DM_out;
    2'b10: select_out = pc4_out;
    default: select_out = 0;
    endcase
endmodule
