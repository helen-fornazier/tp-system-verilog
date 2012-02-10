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
   logic [4:0]    shift_size;
   logic [Nm+1:0] big_m,small_m;
   logic 	  big_s,small_s;
   logic signed   [Ne+1:0] big_e;/*Ne+2 bits, One is for the signal and the other for the overflow*/
   
   
   //sub, change signal of the second op
   if(f==0) op2.s = !op2.s;

   //if one number is zero there's nothing to do
   if(!op1.mantisse && !op1.exposant) return op2;
   else if (!op2.mantisse && !op2.exposant)return op1;
   
   //proceed operation
   else begin
      //prepare operands to calculus
      //find out the biggest one, align the smalest if different exponents
      if (op1.exposant > op2.exposant) begin	 
	 if (op1.exposant-op2.exposant<=Nm+1)
	   shift_size = op1.exposant-op2.exposant;
	 else shift_size = Nm+1;
	 
	 small_m[Nm+1:0] = {1'b0,1'b1,op2.mantisse};
	 small_m = small_m >> shift_size;
	 small_s = op2.s;
	 
	 big_e={2'b0,op1.exposant};
	 big_m[Nm+1:0] = {1'b0,1'b1,op1.mantisse};
	 big_s = op1.s;         
      end // if (op1.exposant > op2.exposant)
      else if (op1.exposant < op2.exposant)begin
	 if (op2.exposant-op1.exposant<=Nm+1)
	   shift_size = op2.exposant-op1.exposant;
	 else shift_size = Nm+1;
	 	
	 small_m[Nm+1:0] = {1'b0,1'b1,op1.mantisse};
	 small_m = small_m >> shift_size;
	 small_s = op1.s;
	 
	 big_e={2'b0,op2.exposant};
	 big_m[Nm+1:0] = {1'b0,1'b1,op2.mantisse};
	 big_s = op2.s;        
      end // if (op1.exposant < op2.exposant)
      else if (op1.exposant == op2.exposant) begin
	 if (op1.mantisse>op2.mantisse)begin
	    small_m[Nm+1:0] = {1'b0,1'b1,op2.mantisse};	   
	    small_s = op2.s;
	    big_e={2'b0,op1.exposant};
	    big_m[Nm+1:0] = {1'b0,1'b1,op1.mantisse};
	    big_s = op1.s; 
	 end
	 else begin
	    small_m[Nm+1:0] = {1'b0,1'b1,op1.mantisse};	    
	    small_s = op1.s;	    
	    big_e = {2'b0,op2.exposant};
	    big_m[Nm+1:0] = {1'b0,1'b1,op2.mantisse};
	    big_s = op2.s;
	 end // else: !if(op1.mantisse>op2.mantisse)
      end // if (op1.exposant = op2.exposant)

      //$display("sBig:%x mBig:%x eBig:%x",big_s, big_m, big_e) ;
     // $display("sSml:%x mSml:%x ",small_s, small_m) ;  
      
      //generate final result (stored in op1)
           
      //first generate signal
      op1.s = big_s;
      
      //then generate mantisse and exponent
      if (big_s==small_s) begin
	 //same signal, perform addition
	 big_m = big_m + small_m;
	 //normalize mantisse and adjust exponent
	 if (big_m[Nm+1])begin
	    big_m = big_m>>1;	    
	    big_e = big_e+1;	    
	    //verify overflow in exp
	    if (big_e[Ne] || big_e[Ne-1:0] == '1) begin
	       big_e = '1;	       
	       big_e = big_e-1;
	       big_m = '1;
	    end
	 end
      end // if (big_s==small_s)
      else begin
	 //different signals, perform subtracttion
	 big_m = big_m - small_m;
	 //normalize results
	 for (shift_size=0; shift_size<Nm && (big_m[Nm]==0); shift_size++)
	   big_m = big_m << 1;
	 //adjust exponent
	 big_e = big_e - shift_size;
	 //check underflow in exp
	 if(big_e <= 0) begin
	    big_e = '0;
	    big_m = '0;	    
	 end
      end // else: !if(big_s==small_s)
      op1.mantisse[Nm-1:0] = big_m[Nm-1:0];
      op1.exposant[Ne-1:0] = big_e[Ne-1:0];
      return op1;     
	
   end // else: !if(!op2.mantisse && !op2.exposant)

      
        
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
