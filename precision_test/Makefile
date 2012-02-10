src_dir = ../LM32_SYNTH_COPRO/copro_src
pack_file = ${src_dir}/float_pack.sv

all:mult add div sub

%: $(pack_file) %_ieee.sv
	vlog +acc $^
        
