import float_pack::*;
module float_copro_dp(opcode, op0, op1, result);

   input  logic[10:0]        opcode;
   input  logic[31:0]        op0;
   input  logic[31:0]        op1;
   output logic[31:0]        result;
     
   always_comb
     begin
        result <= '0;
        case (opcode)
          //somme
          11'd0:
            //result <= op0 + op1;
            result <= float_add(op0, op1);
          //soustraction
          11'd1:
            //result <= op0 - op1;
            result <= float_sub(op0, op1);
          //multiplication
          11'd2:
            //result <= op0 * op1;
            result <= float_mul(op0, op1);
	  //division
	  11'd3:
            //result <= op0 / op1;
            result <= float_div(op0, op1);
        endcase
     end
     
endmodule
