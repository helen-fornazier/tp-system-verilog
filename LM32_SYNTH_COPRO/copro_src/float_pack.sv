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
        logic s;
        logic [Ne:0]exp;
        logic [Nm:0]mant;
} float;

typedef struct packed {
        logic s;
        logic [8:0]exp;
        logic [23:0]mant;
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
endfunction

endpackage : float_pack
