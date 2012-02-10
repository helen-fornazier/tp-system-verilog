import float_pack::*;

module mult_ieee(input float op1,
                 input float op2,
                 output float result
                 );
                 
assign result = float_mul(op1, op2);

endmodule
