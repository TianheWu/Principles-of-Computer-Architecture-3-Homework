module TC_module(clk, rst, we, ADDr_in, Data_in, Data_out, IRQ);
    input clk, rst, we;
    input [1:0]ADDr_in;
    input [31:0]Data_in;
    output [31:0]Data_out;
    output IRQ;
    reg [31:0]CTRL;
    reg [31:0]PRESET;
    reg [31:0]COUNT;
    
    assign Data_out = (ADDr_in == 2'b00) ? CTRL : 
                      (ADDr_in == 2'b01) ? PRESET :
                      (ADDr_in == 2'b10) ? COUNT : 32'h00000000;
    
    assign IRQ = (CTRL[3] & CTRL[0] & COUNT == 32'h00000000) ? 1 : 0;
    
    always @ (posedge clk or posedge rst)
    if(rst)
      begin
        CTRL <= 32'h00000000;
        PRESET <= 32'h00000000;
        COUNT <= 32'h00000000;
      end
    else
      begin
      if(we)
        case(ADDr_in)
          2'b00: CTRL <= Data_in;
          2'b01: begin
                 PRESET <= Data_in;
                 COUNT <= Data_in;
                 CTRL[0] <= 1'b1;
                 end
          2'b10: COUNT <= COUNT;
        endcase
      if(CTRL[2:1] == 2'b00)
        begin
          if(COUNT == 32'h00000000 && CTRL[0] == 1)
              CTRL[0] <= 0;
          else 
            if(CTRL[0] == 1)
              COUNT <= COUNT - 1;  
        end
        
      else if(CTRL[2:1] == 2'b01)
        begin
          if(COUNT == 32'h00000000)
            begin
              CTRL[0] <= 0;
              COUNT <= PRESET;
              CTRL[0] <= 1;
            end
          else 
            if(CTRL[0] == 1)
              COUNT <= COUNT - 1;
        end
        
       end
       
endmodule
    
    