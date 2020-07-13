module Output_Device_module(clk, rst, Data_in, Data_out, sel_signal, we);
    input clk, rst, we, sel_signal;
    input [31:0]Data_in;
    output [31:0]Data_out;
    reg [31:0]initial_reg;
    reg [31:0]current_reg;
    
    assign Data_out = (sel_signal == 1) ? current_reg : initial_reg;
    
    always @ (posedge clk or posedge rst)
        if(rst)
          begin
          initial_reg <= 0;
          current_reg <= 0;
          end
        else 
          if(we)
          begin
          if(sel_signal)
            begin
              current_reg <= Data_in;
            end
          else 
            begin
              initial_reg <= Data_in;
              current_reg <= Data_in;
            end
          end
endmodule