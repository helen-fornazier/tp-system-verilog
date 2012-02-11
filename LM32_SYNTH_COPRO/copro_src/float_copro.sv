// Squelette du coprocesseur flottant
module float_copro #(
	       parameter t_mult = 2, /*Tmin 10.450 (95.694 MHz)*/
               parameter t_add = 3, /*Tmin 20.712 (48.281 MHz)*/
               parameter t_sub = 3, /*Tmin 20.712 (48.281 MHz)*/
	       parameter t_div = 12) /*Tmin 106.406 (9.398 MHz)*/
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
// synthesis translate_off
   shortreal fop0;
   shortreal fop1;
   shortreal fresultat;

   always @( * )
   begin
        fop0     = $bitstoshortreal( op0 );
        fop1     = $bitstoshortreal( op1 );
        fresultat= $bitstoshortreal( resultat );
   end
// synthesis translate_on
   
   //////////////////////////////////////////////////
   // Compléter en rajoutant registres et contrôle //
   //////////////////////////////////////////////////

   int COUNT;
   logic inactiv;

   always_ff @ (posedge clk)
     begin
	if (copro_accept) begin
           copro_complete <= 0;
           inactiv = 0;
           COUNT = 0;
	end
	else if (!inactiv) begin
           if (COUNT == 0 && copro_valid) begin
              op0 <= copro_op0;
              op1 <= copro_op1;
              opcode <= copro_opcode;
              case (copro_opcode)
		11'd0: COUNT = t_add;
		11'd1: COUNT = t_sub;
		11'd2: COUNT = t_mult;
		11'd3: COUNT = t_div;
              endcase // case (copro_opcode)
           end // if (COUNT == 0 && copro_valid)
           else if (COUNT) begin
              COUNT = COUNT - 1;
              if (COUNT == 0) begin
                 copro_complete <= 1;
                 inactiv = 1;
                 copro_result <= resultat;
                 COUNT = 0;
              end
           end
	end // if (!inactiv)
     end // always_ff @
endmodule // float_copro
