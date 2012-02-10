import float_pack::*;

module div_ieee(input float op1,
                 input float op2,
                 output float result
                 );
                 
assign result = float_div(op1, op2);

endmodule
