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

endpackage : float_pack
   
