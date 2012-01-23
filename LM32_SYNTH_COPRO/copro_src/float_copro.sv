// Squelette du coprocesseur flottant
module float_copro #(
               parameter t_mult = 5,
               parameter t_add = 3,
               parameter t_sub = 2)  
               (input logic clk,
               input logic copro_valid,
               input logic copro_accept,
               input logic [10:0] copro_opcode,
               input logic [31:0] copro_op0,
               input logic [31:0] copro_op1,
               output logic copro_complete, 
               output logic[31:0] copro_result
               );

   //registres des opérandes
   logic [31:0]               op0;
   logic [31:0]               op1;
   logic [31:0]               resultat;

   //opération a réaliser
   logic [10:0]               opcode;

   //le datapath
   float_copro_dp datapath(opcode,op0,op1,resultat);
   
   //////////////////////////////////////////////////
   // Compléter en rajoutant registres et contrôle //
   //////////////////////////////////////////////////

   int COUNT;

   initial
   begin
      COUNT = 0;
      copro_complete = 0;
   end

   always_ff @ (posedge clk)
   begin
      if (copro_accept) begin
         copro_complete = 0;
      end
      else if (!copro_complete) begin
              if (COUNT == 0 && copro_valid) begin
                 op0 = copro_op0;
                 op1 = copro_op1;
                 opcode = copro_opcode;
                 COUNT = COUNT + 1;
              end
              else if (COUNT) case (opcode)
                //somme
                 11'd0:
                    if (COUNT >= t_add) begin
                       copro_complete = 1;
                       copro_result = resultat;
                       COUNT = 0;
                    end  
                    else COUNT = COUNT + 1;
                //soustraction
                 11'd1:
                    if (COUNT >= t_sub) begin
                       copro_complete = 1;
                       copro_result = resultat;
                       COUNT = 0;
                    end  
                    else COUNT = COUNT + 1;
                //multiplication
                 11'd2:
                    if (COUNT >= t_mult) begin
                       copro_complete = 1;
                       copro_result = resultat;
                       COUNT = 0;
                    end  
                    else COUNT = COUNT + 1;
              endcase
      end
   end
endmodule

