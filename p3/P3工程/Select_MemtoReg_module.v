module Select_MemtoReg_module(ALU_out, DM_out, pc4_out, MemtoReg, select_out, MFC0_in, bridge_in);
    input [31:0]ALU_out, DM_out, pc4_out, MFC0_in, bridge_in;
    input [2:0]MemtoReg;
    output [31:0]select_out;
    reg [31:0]select_out;
    always @ (*)
    case(MemtoReg)
    3'b000: select_out = ALU_out;
    3'b001: select_out = DM_out;
    3'b010: select_out = pc4_out;
    3'b100: select_out = MFC0_in;
    3'b101: select_out = bridge_in;
    default: select_out = 0;
    endcase
endmodule
