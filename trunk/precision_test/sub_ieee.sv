import float_pack::*;

module sub_ieee(input float op1,
                 input float op2,
                 output float result
                 );
                 
assign result = float_add_sub(0, op1, op2);

endmodule
