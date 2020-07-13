module Bridge_module(We_CPU, PrAddr, PrWD, DEV_Addr, DEV_WD, PrRD, DEV1_RD, DEV2_RD, DEV3_RD, Output_Device_we, TC_we);
    input [31:0]PrAddr;
    input [31:0]PrWD;
    input [31:0]DEV1_RD, DEV2_RD, DEV3_RD;
    input We_CPU; // sw, sb
    output [1:0]DEV_Addr;
    output [31:0]DEV_WD;
    output [31:0]PrRD;
    output Output_Device_we, TC_we;
    
    wire DEV1_RD_Address, DEV2_RD_Address, DEV3_RD_Address;
    assign DEV1_RD_Address = (PrAddr >= 32'h00007f00 && PrAddr <= 32'h00007f08); // TC
    assign DEV2_RD_Address = (PrAddr == 32'h00007f14 || PrAddr == 32'h00007f18); // OD
    assign DEV3_RD_Address = (PrAddr == 32'h00007f20); // ID
    
    assign PrRD = (DEV1_RD_Address) ? DEV1_RD :
                  (DEV2_RD_Address) ? DEV2_RD :
                  (DEV3_RD_Address) ? DEV3_RD : 32'h00000000;
                  
    assign TC_we = We_CPU & DEV1_RD_Address;
    assign Output_Device_we = We_CPU & DEV2_RD_Address;
    
    assign DEV_Addr = PrAddr[3:2];
    assign DEV_WD = PrWD;
    
endmodule
    
