
create_clock -name clk -period 10.0 [get_ports clk] 


set_input_delay 2.0 -clock clk [get_ports reset]


set_output_delay 2.0 -clock clk [get_ports done]

set_dont_touch [get_ports reset]

