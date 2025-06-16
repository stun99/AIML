if { [info exists synopsys_program_name ] && ($synopsys_program_name == "icc2_shell") } {
    puts " Creating ICC2 MCMM "
    create_mode func
    create_corner slow
    create_scenario -mode func -corner slow -name func_slow
    current_scenario func_slow
    set_operating_conditions ss0p75vn40c
    read_parasitic_tech -tlup $tlu_dir/saed32nm_1p9m_Cmax.tluplus -layermap $tlu_dir/saed32nm_tf_itf_tluplus.map -name Cmax
    read_parasitic_tech -tlup $tlu_dir/saed32nm_1p9m_Cmin.tluplus -layermap $tlu_dir/saed32nm_tf_itf_tluplus.map -name Cmin
   
	set_parasitic_parameters -early_spec Cmax -early_temperature -40
    set_parasitic_parameters -late_spec Cmax -late_temperature -40
    #set_parasitic_parameters -early_spec 1p9m_Cmax -early_temperature 40
    #set_parasitic_parameters -late_spec 1p9m_Cmax -late_temperature 40

    #set_scenario_status  default -active false
    set_scenario_status func_slow -active true -hold true -setup true
}
create_clock -name "clk" -period 1 -waveform {0.0 0.5} clk

set_clock_latency 0.1 clk
set_clock_transition 0.1 clk
set_clock_uncertainty 0.070 clk
set_input_delay 0.6 -clock clk [all_inputs] 
set_output_delay 0.6 -clock clk [all_outputs]
set_drive 0.00001 [all_inputs]
set_load 0.1 [all_outputs]
set_input_transition 0.1 [all_inputs]
set_max_capacitance 2.0 [current_design]
set_max_transition 2.0 [current_design]


group_path -name INTERNAL -from [all_clocks] -to [all_clocks ]
group_path -name INPUTS -from [ get_ports -filter "direction==in&&full_name!~*clk*" ]
group_path -name OUTPUTS -to [ get_ports -filter "direction==out" ]


