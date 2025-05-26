@echo off 
set "COCOTB_RESOLVE_X=" 
set MODULE=test_spi 
set TOPLEVEL=spi_slave 
set SIM=questa 
set VERILOG_SOURCES=rtl/spi_slave.v 
set PYTHONPATH=tb 
echo Running ModelSim simulation... 
cmd /c "python -m cocotb.regression" 
pause 
