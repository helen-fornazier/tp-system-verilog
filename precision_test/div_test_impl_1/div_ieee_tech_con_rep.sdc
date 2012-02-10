###################################################################################
# Mentor Graphics Corporation
#
###################################################################################

#################
# Attributes
#################
set_attribute -name dataa_width -value "18" -instance cycloneii_mac_mult_0 -design gatelevel 
set_attribute -name datab_width -value "18" -instance cycloneii_mac_mult_0 -design gatelevel 
set_attribute -name dataa_clock -value "none" -instance cycloneii_mac_mult_0 -design gatelevel 
set_attribute -name datab_clock -value "none" -instance cycloneii_mac_mult_0 -design gatelevel 
set_attribute -name signa_clock -value "none" -instance cycloneii_mac_mult_0 -design gatelevel 
set_attribute -name signb_clock -value "none" -instance cycloneii_mac_mult_0 -design gatelevel 
set_attribute -name lpm_hint -value "false" -instance cycloneii_mac_mult_0 -design gatelevel 
set_attribute -name dataa_width -value "36" -instance cycloneii_mac_out_1 -design gatelevel 
set_attribute -name output_clock -value "none" -instance cycloneii_mac_out_1 -design gatelevel 
set_attribute -name lpm_hint -value "TRUE" -instance cycloneii_mac_out_1 -design gatelevel 
set_attribute -name dataa_width -value "18" -instance cycloneii_mac_mult_2 -design gatelevel 
set_attribute -name datab_width -value "18" -instance cycloneii_mac_mult_2 -design gatelevel 
set_attribute -name dataa_clock -value "none" -instance cycloneii_mac_mult_2 -design gatelevel 
set_attribute -name datab_clock -value "none" -instance cycloneii_mac_mult_2 -design gatelevel 
set_attribute -name signa_clock -value "none" -instance cycloneii_mac_mult_2 -design gatelevel 
set_attribute -name signb_clock -value "none" -instance cycloneii_mac_mult_2 -design gatelevel 
set_attribute -name lpm_hint -value "false" -instance cycloneii_mac_mult_2 -design gatelevel 
set_attribute -name dataa_width -value "36" -instance cycloneii_mac_out_3 -design gatelevel 
set_attribute -name output_clock -value "none" -instance cycloneii_mac_out_3 -design gatelevel 
set_attribute -name lpm_hint -value "TRUE" -instance cycloneii_mac_out_3 -design gatelevel 
set_attribute -name dataa_width -value "18" -instance cycloneii_mac_mult_4 -design gatelevel 
set_attribute -name datab_width -value "18" -instance cycloneii_mac_mult_4 -design gatelevel 
set_attribute -name dataa_clock -value "none" -instance cycloneii_mac_mult_4 -design gatelevel 
set_attribute -name datab_clock -value "none" -instance cycloneii_mac_mult_4 -design gatelevel 
set_attribute -name signa_clock -value "none" -instance cycloneii_mac_mult_4 -design gatelevel 
set_attribute -name signb_clock -value "none" -instance cycloneii_mac_mult_4 -design gatelevel 
set_attribute -name lpm_hint -value "false" -instance cycloneii_mac_mult_4 -design gatelevel 
set_attribute -name dataa_width -value "36" -instance cycloneii_mac_out_5 -design gatelevel 
set_attribute -name output_clock -value "none" -instance cycloneii_mac_out_5 -design gatelevel 
set_attribute -name lpm_hint -value "TRUE" -instance cycloneii_mac_out_5 -design gatelevel 
set_attribute -name dataa_width -value "9" -instance cycloneii_mac_mult_6 -design gatelevel 
set_attribute -name datab_width -value "9" -instance cycloneii_mac_mult_6 -design gatelevel 
set_attribute -name dataa_clock -value "none" -instance cycloneii_mac_mult_6 -design gatelevel 
set_attribute -name datab_clock -value "none" -instance cycloneii_mac_mult_6 -design gatelevel 
set_attribute -name signa_clock -value "none" -instance cycloneii_mac_mult_6 -design gatelevel 
set_attribute -name signb_clock -value "none" -instance cycloneii_mac_mult_6 -design gatelevel 
set_attribute -name lpm_hint -value "false" -instance cycloneii_mac_mult_6 -design gatelevel 
set_attribute -name dataa_width -value "18" -instance cycloneii_mac_out_7 -design gatelevel 
set_attribute -name output_clock -value "none" -instance cycloneii_mac_out_7 -design gatelevel 
set_attribute -name lpm_hint -value "TRUE" -instance cycloneii_mac_out_7 -design gatelevel 

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
