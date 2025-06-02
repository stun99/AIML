SIM = icarus
TOPLEVEL = spi_slave
MODULE = spi_test
VERILOG_SOURCES = spi_slave.v

sim:
	@echo "Starting SPI Master-Slave Cosimulation..."
	@set COCOTB_RESOLVE_X= && set MODULE=$(MODULE) && set TOPLEVEL=$(TOPLEVEL) && set SIM=$(SIM) && set VERILOG_SOURCES=$(VERILOG_SOURCES) && python -m cocotb.regression

clean:
	@if exist work rmdir /s /q work
	@if exist *.wlf del *.wlf
	@if exist transcript del transcript

.PHONY: sim clean