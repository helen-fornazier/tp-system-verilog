package float_pack; 
   // Ajouter ici les définition des fonctions
   // utilisée par votre coprocesseur
`ifdef TB_MANT_SIZE
   parameter Nm = `TB_MANT_SIZE ;
`else
   parameter Nm = 23 ;
`endif
   
`ifdef TB_EXP_SIZE
   parameter Ne = `TB_EXP_SIZE ;	
`else
   parameter Ne = 8;
`endif

   typedef struct packed {
      logic 	  s;
      logic [Ne-1:0] exposant;
      logic [Nm-1:0] mantisse;
   } float;

   typedef struct  packed {
      logic 	   s;
      logic [7:0]  exposant;
      logic [22:0] mantisse;
   } float_ieee;

/*-------- Calcul Flotant --------*/

function float float_mul(float op1, float op2);
        automatic float result = 0;
        automatic logic [2*Nm+1:0]man_tmp = 0; /*2*Nm+2 bits*/
        automatic logic signed [Ne+1:0] exp_tmp = 0; /*Ne+2 bits, One is for the signal and the other for the overflow*/
        automatic logic [Nm:0] op1_tmp;
        automatic logic [Nm:0] op2_tmp;

        /*op concatenation*/
        op1_tmp[Nm:0] = {1'b1,op1.mantisse[Nm-1:0]};
        op2_tmp[Nm:0] = {1'b1,op2.mantisse[Nm-1:0]};

        /*Signal*/
        result.s = op1.s ^ op2.s;

        /*Exposant*/
        exp_tmp = op1.exposant + op2.exposant - (2**(Ne-1) - 1);
        if ((exp_tmp < 0) || (!op1.exposant && !op1.mantisse)||(!op2.exposant && !op2.mantisse)) begin
                result.exposant = 0;
                result.mantisse = 0;
        end
        else begin
                /*Mantisse*/
                man_tmp = op1_tmp*op2_tmp;
                if (man_tmp[2*Nm+1]) begin
                        result.mantisse[Nm-1:0] = man_tmp[2*Nm:Nm+1];
                        exp_tmp++;
                end
                else result.mantisse[Nm-1:0] = man_tmp[2*Nm-1:Nm];

                /*Saturation and overflow*/
                if (exp_tmp[Ne] || exp_tmp[Ne-1:0] == '1) begin
                        result.exposant = '1;
                        result.mantisse = '0;
                end
                else if (exp_tmp == 0) result.mantisse = '0;
                else result.exposant[Ne-1:0] = exp_tmp[Ne-1:0];
        end // else: !if((exp_tmp < 0) || (!op1.exposant && !op1.mantisse)||(!op2.exposant && !op2.mantisse))
        /*Answer*/
        return result;
endfunction // float_mul

/*Somme f=1, Sub f=0*/
function float float_add_sub(logic f, float op1, float op2);   
   logic [Ne-1:0]    shift_size, first_one;
   float smallf, bigf;
   float result;
   logic [Nm+1:-1] big_m,small_m,result_m;
   logic 	  big_s,small_s;
   logic signed   [Ne+1:0] big_e, result_e;/*Ne+2 bits, One is for the signal and the other for the overflow*/
   
   
   //sub, change signal of the second op
   if(f==0) op2.s = !op2.s;
   
   //prepare operands to calculus
   //find out the biggest one
   bigf = op1;
   smallf = op2;   
   if ({op2.exposant,op2.mantisse} > {op1.exposant, op1.mantisse}) 
     begin
	bigf = op2;
	smallf = op1;
     end
   //if one number is zero there's nothing to do
   if ({smallf.exposant, smallf.mantisse} == '0)
     return bigf;
   //$display("INIT") ; 
   //$display("sSml:%x mSml:%x ",smallf.s, smallf.mantisse) ; 
   // align the smalest if different exponents
   shift_size = bigf.exposant-smallf.exposant;      
   small_m[Nm+1:-1] = {1'b0,1'b1,smallf.mantisse,1'b0};
   small_m = small_m >> shift_size;
   
   big_e = {2'b0,bigf.exposant};
   big_m[Nm+1:-1] = {1'b0,1'b1,bigf.mantisse,1'b0};
  
   //$display("sBig:%x mBig:%x eBig:%x",bigf.s, bigf.mantisse, bigf.exposant) ;
   //$display("sSml:%x mSml:%x ",smallf.s, small_m) ;  
   
   //generate final result (stored in result)
   
   //first generate signal
   result.s  = bigf.s;
   
   //then generate mantisse and exponent
   if (bigf.s==smallf.s) 
     //same signal, perform addition
     result_m = big_m + small_m;
   else 
     //different signals, perform subtraction
     result_m = big_m - small_m;      
   //normalize results and find first one
   for (first_one = 0; first_one <=Nm && (result_m[Nm+1]==0); first_one++)
     result_m = result_m << 1;
   //check if mantisse is zero and adjust exponent accordingly	 
   if (result_m=='0) result_e='0;
   else begin     
      result_e = big_e - first_one + 1;	 
      //check under/overflow in exp
      if(result_e <= 0) begin
	 result_e = '0;
	 result_m = '0;	    
      end
      else if (result_e[Ne] == 1'b1 || result_e[Ne-1:0] == '1) begin
	 result_e = '1;	       
	 result_e = result_e-1'b1;
	 result_m = '1;
      end
   end // else: !if(result_m=='0)

   result.mantisse[Nm-1:0] = result_m[Nm:1];
   result.exposant[Ne-1:0] = result_e[Ne-1:0];
return result;     
	

endfunction // float_add_sub


function float float_div(float op1, float op2);
        automatic float result = 0;
        automatic logic [Nm:0]man_tmp = 0; /*Nm+1 bits*/
        automatic logic signed [Ne+1:0] exp_tmp = 0; /*Ne+2 bits, One is for the signal and the other for the overflow*/
        automatic logic [2*Nm+1:0] op1_tmp = 0;
        automatic logic [Nm:0] op2_tmp = {1'b1,op2.mantisse[Nm-1:0]};
        result = '0;

        /*op1 shift*/
        op1_tmp[2*Nm+1:Nm] = {1'b1,op1.mantisse[Nm-1:0]};
        op2_tmp[Nm:0] = {1'b1,op2.mantisse[Nm-1:0]};

        /*Signal*/
        result.s = op1.s ^ op2.s;

        /*Exposant*/
        exp_tmp = op1.exposant - op2.exposant + (2**(Ne-1) - 1);
        if ((exp_tmp < 0) || (!op1.exposant && !op1.mantisse)) begin
                result.exposant = 0;
                result.mantisse = 0;
        end
        /*Division by zero*/
        else if (!op2.exposant && !op2.mantisse) begin
                        result.exposant = '1;
                        result.mantisse = '0;
        end
        else begin
                /*Mantisse*/
                /*Integer Division*/
                man_tmp = op1_tmp/op2_tmp;
                /*Rounding*/
                if(op2_tmp*man_tmp-op1_tmp >= op2_tmp/2) man_tmp++;

                if (man_tmp[Nm]==0 && man_tmp[Nm-1]) begin
                        result.mantisse[Nm-1:1] = man_tmp[Nm-2:0];
                        exp_tmp--;
                        /*Reverifying exposant*/
                        if (exp_tmp < 0) begin
                                result.exposant = 0;
                                result.mantisse = 0;
                                return result;
                        end
                end
                else result.mantisse[Nm-1:0] = man_tmp[Nm-1:0];

                /*Saturation and overflow*/
                if (exp_tmp[Ne] || exp_tmp[Ne-1:0] == '1) begin
                        result.exposant = '1;
                        result.mantisse = '0;
                end
                else if (exp_tmp == 0) result.mantisse = '0;
                else result.exposant[Ne-1:0] = exp_tmp[Ne-1:0];
        end // else: !if(!op2.exposant && !op2.mantisse)
        /*Answer*/
        return result;
endfunction // float_div

function float float_add(float op1, float op2);
        return float_add_sub(1, op1, op2);
endfunction // float_add

function float float_sub(float op1, float op2);
        return float_add_sub(0, op1, op2);
endfunction // float_sub

/*---------- Convertion ----------*/
   // synthesis translate_off
   function float_ieee real2float_ieee(shortreal number);
      return $shortrealtobits(number);
   endfunction // real2float_ieee

   function shortreal float_ieee2real(float_ieee number);
      return $bitstoshortreal(number);
   endfunction // float_ieee2real

   function float real2float (shortreal number);
      float_ieee nieee;
      float n;
      nieee = real2float_ieee (number);  
      //truncate
      n.s = nieee.s;
      n.mantisse[Nm-1:0] = nieee.mantisse[22:23-Nm];      
      n.exposant[Nm-1:0] = nieee.exposant[7:0] - (2**(Ne-1)) + 128;
      return n;    
   endfunction // real2float
   
   function shortreal float2real (float n);
      float_ieee nieee;
      shortreal  number;
      nieee.s = n.s;      
      nieee.mantisse[22:0] = 0;
      nieee.mantisse[22:23-Nm] = n.mantisse[Nm-1:0];      
      nieee.exposant[7:0] = n.exposant[Ne-1:0] + (2**(Ne-1)) - 128;
      number = float_ieee2real(nieee); 
      return number;    
   endfunction // float2real
   // synthesis translate_on
endpackage : float_pack
