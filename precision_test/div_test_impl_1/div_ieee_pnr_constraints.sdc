###################################################################################
# Mentor Graphics Corporation
#
###################################################################################


##################
# Clocks
##################
create_clock  -name Design_Clock -period 10.000000

##################
# Input delays
##################
set_input_delay  -clock Design_Clock -add_delay 0.000 {op1_exposant[*] op1_mantisse[*] op1_s op2_exposant[*] op2_mantisse[*] op2_s}

###################
# Output delays
###################
set_output_delay  -clock Design_Clock -add_delay 0.000 {result_exposant[*] result_mantisse[*] result_s}
