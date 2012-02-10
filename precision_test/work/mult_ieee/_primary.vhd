library verilog;
use verilog.vl_types.all;
library work;
entity mult_ieee is
    port(
        op1             : in     work.float_pack.float;
        op2             : in     work.float_pack.float;
        result          : out    work.float_pack.float
    );
end mult_ieee;
