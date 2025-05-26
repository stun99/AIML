@echo off 
set "COCOTB_RESOLVE_X=" 
set MODULE=test_spi 
set TOPLEVEL=spi_slave 
set SIM=questa 
set VERILOG_SOURCES=rtl/spi_slave.v 
set PYTHONPATH=tb 
set COCOTB_LOG_LEVEL=INFO 
echo === Environment Check === 
echo MODULE: %test_spi % 
echo TOPLEVEL: %spi_slave % 
echo SIM: %questa % 
echo. 
echo Testing Python import... 
python -c "import sys; sys.path.insert(0, 'tb'); import test_spi; print('û Test imported successfully')" 
echo. 
echo Running ModelSim simulation... 
python -m cocotb.regression 
echo. 
echo Checking output files... 
if exist *.wlf echo û ModelSim waveform file created 
if exist results.xml echo û Test results file created 
if not exist *.wlf echo ? No waveform files found 
if not exist results.xml echo ? No results file found 
pause 
