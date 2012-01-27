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
        //TODO
        return real2float(float2real(op1)*float2real(op2));
endfunction

/*Somme f=1, Sub f=0*/
function float float_add_sub(logic f, float op1, float op2);
        //TODO
        if(f) return real2float(float2real(op1)+float2real(op2));
        else return real2float(float2real(op1)-float2real(op2));
endfunction

function float float_div(float op1, float op2);
        //TODO
        return real2float(float2real(op1)/float2real(op2));
endfunction

function float float_add(float op1, float op2);
        return float_add_sub(1, op1, op2);
endfunction

function float float_sub(float op1, float op2);
        return float_add_sub(0, op1, op2);
endfunction

/*---------- Convertion ----------*/

   function float_ieee real2float_ieee(shortreal number);
      return $shortrealtobits(number);
   endfunction

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
   endfunction // real2float

endpackage : float_pack