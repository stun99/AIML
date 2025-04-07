
create_clock -name clk -period 10 [get_ports clk]         
create_clock -name spi_clk -period 40 [get_ports spi_clk] 

set_clock_groups -asynchronous -group {clk} -group {spi_clk} 


set_input_delay -clock clk -max 2 [get_ports sensor_inputs[*]]  
set_input_delay -clock spi_clk -max 5 [get_ports spi_mosi]      
set_input_delay -clock spi_clk -max 5 [get_ports spi_cs_n]      


set_output_delay -clock clk -max 3 [get_ports actuator_outputs[*]] 
set_output_delay -clock spi_clk -max 2 [get_ports spi_miso]        

set_false_path -from [get_ports spi_cs_n] -to [get_clocks clk]    
set_multicycle_path 2 -setup -from [get_clocks spi_clk] -to [get_clocks clk] 

set_max_delay 8 -from [get_pins network/layer_neurons/*/membrane_potential] \
                 -to [get_pins network/layer_neurons/*/spike_out]


foreach_in_collection cell [get_cells weight_mem[*]] {
    set_disable_timing $cell -from CLK -to Q                    
}


set_max_delay 15 -from [get_pins reg_addr_reg] \
                 -to [get_pins weight_mem/WE]

