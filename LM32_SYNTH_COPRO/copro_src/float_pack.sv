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
                man_tmp = {1,op1.mantisse}*{1,op2.mantisse};
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
        end
        /*Answer*/
        return result;
endfunction // float_mul

/*Somme f=1, Sub f=0*/
function float float_add_sub(logic f, float op1, float op2);   
   logic [4:0] 	   shift_size;
   logic [Nm+1:0] big_m,small_m;
   logic 	big_s,small_s;
   logic [Ne-1:0] big_e;
   
   
   //sub, change signal of the second op
   if(f==0) op2.s = !op2.s;

   //if one number is zero there's nothing to do
   if(op1.mantisse==0 && op1.exposant==0) return op2;
   else if (op2.mantisse==0 && op2.exposant==0)return op1;
   //proceed operation
   else begin   
      if (op1.exposant >= op2.exposant) begin
	 shift_size = op1.exposant-op2.exposant;
	 big_e=op1.exposant;
	 big_m[Nm+1:0] = {'1b0,'1b1,op1.mantisse};
	 big_s = op1.s;      
	 small_m[Nm+1:0] = {'1b0,'1b1,op2.mantisse} >> shift_size;
	 small_s = op1.s;    
      end
      else begin
	 shift_size = op2.exposant-op1.exposant;
	 big_e=op2.exposant;
	 big_m[Nm+1:0] = {'1b0,'1b1,op2.mantisse};
	 big_s = op2.s;  
	 small_m[Nm+1:0] = {'1b0,'1b1,op1.mantisse} >> shift_size;
	 small_s = op1.s;      
      end // else: !if(op1.exposant >= op2.exposant)
      
      op1.s = big_s;
      
      if (big_s==small_s) begin
	 big_m = big_m + small_m;
	 if (big_m[Nm+1])begin
	    op1.exposant = big_e+1;
	    op1.mantisse = big_m[Nm:1];
	 end
	 else begin
	    op1.exposant = big_e;
	    op1.mantisse = big_m[Nm-1:0];
	 end	 
      else begin
	 big_m = big_m - small_m;
	 for (shift_size=0;shift_size<Nm;shifit_size++)
	   if (big_m[Nm])
	 
      end

      
      
      
   end // else: !if(op2.mantisse==0 && op2.exposant==0)
      
   
        
endfunction // float_add_sub

function float float_div(float op1, float op2);
        //TODO
        return real2float(float2real(op1)/float2real(op2));
endfunction // float_div

function float float_add(float op1, float op2);
        return float_add_sub(1, op1, op2);
endfunction // float_add

function float float_sub(float op1, float op2);
        return float_add_sub(0, op1, op2);
endfunction // float_sub

/*---------- Convertion ----------*/

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

endpackage : float_pack
