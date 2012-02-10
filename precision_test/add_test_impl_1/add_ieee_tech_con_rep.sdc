###################################################################################
# Mentor Graphics Corporation
#
###################################################################################

#################
# Attributes
#################

##################
# Clocks
##################
create_clock  -domain Design_Clock -name Design_Clock -period 10.000000 -waveform { 0.000000 5.000000 } -design gatelevel 

##################
# Input delays
##################
set_input_delay 0.000 -clock Design_Clock -add_delay  -design gatelevel  {op1_exposant(*) op1_mantisse(*) op1_s op2_exposant(*) op2_mantisse(*) op2_s}

###################
# Output delays
###################
set_output_delay 0.000 -clock Design_Clock -add_delay  -design gatelevel  {result_exposant(*) result_mantisse(*) result_s}
