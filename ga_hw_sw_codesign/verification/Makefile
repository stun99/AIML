# CocoTB Makefile for GA Coprocessor Hardware-Software Cosimulation
# Place this file in verification/ directory

# Simulator selection (icarus is most compatible)
SIM ?= icarus

# Top-level module name (must match your Verilog module)
TOPLEVEL = ga_coprocessor

# All Verilog source files
VERILOG_SOURCES = ../hardware/ga_coprocessor.v
VERILOG_SOURCES += ../hardware/ga_processing_core.v
VERILOG_SOURCES += ../hardware/fitness_calculator.v
VERILOG_SOURCES += ../hardware/axi4_lite_slave.v
VERILOG_SOURCES += ../hardware/lfsr_32bit.v
VERILOG_SOURCES += ../hardware/population_memory.v

# Python test module (without .py extension)
MODULE = test_ga_coprocessor

# CocoTB settings
export COCOTB_REDUCED_LOG_FMT = 1
export PYTHONPATH := $(PWD):$(PYTHONPATH)

# Simulator-specific settings
ifeq ($(SIM),icarus)
    COMPILE_ARGS += -I../hardware
    COMPILE_ARGS += -DSIM_ICARUS
    # Don't use -g2012 as your Icarus version doesn't support it
    # COMPILE_ARGS += -g2012
endif

ifeq ($(SIM),verilator)
    COMPILE_ARGS += --cc --exe --build -j
    COMPILE_ARGS += -Wall -Wno-UNUSED -Wno-UNOPTFLAT
    COMPILE_ARGS += -I../hardware
    COMPILE_ARGS += -DSIM_VERILATOR
endif

ifeq ($(SIM),questa)
    COMPILE_ARGS += -2008
    COMPILE_ARGS += +incdir+../hardware
    COMPILE_ARGS += -DSIM_QUESTA
endif

# Waveform generation
WAVES ?= 1
ifeq ($(WAVES),1)
    ifeq ($(SIM),icarus)
        COMPILE_ARGS += -DWAVES
        PLUSARGS += +WAVES
    endif
    ifeq ($(SIM),verilator)
        COMPILE_ARGS += --trace --trace-structs
    endif
endif

# Test selection - you can run specific tests
TESTCASE ?= test_complete_ga_flow

# Random seed for reproducible results
RANDOM_SEED ?= 12345
PLUSARGS += +seed=$(RANDOM_SEED)

# CocoTB log level (DEBUG, INFO, WARNING, ERROR)
export COCOTB_LOG_LEVEL = INFO

# Include the CocoTB Makefile (this does all the heavy lifting)
include $(shell cocotb-config --makefiles)/Makefile.sim

# Custom targets for easy testing
.PHONY: test-basic test-ga test-axi test-all waves clean help

# Run basic functionality test
test-basic:
	$(MAKE) TESTCASE=test_basic_functionality

# Run complete GA test
test-ga:
	$(MAKE) TESTCASE=test_complete_ga_flow

# Run AXI protocol test
test-axi:
	$(MAKE) TESTCASE=test_axi_protocol

# Run all tests
test-all:
	$(MAKE) TESTCASE=test_basic_functionality
	$(MAKE) TESTCASE=test_axi_protocol  
	$(MAKE) TESTCASE=test_complete_ga_flow

# Open waveform viewer (requires gtkwave)
waves:
	@if [ -f dump.vcd ]; then \
		echo "Opening GTKWave..."; \
		gtkwave dump.vcd ga_waveform.gtkw 2>/dev/null || gtkwave dump.vcd & \
	else \
		echo "No waveform file found. Run simulation with WAVES=1"; \
	fi

# Clean up generated files
clean::
	rm -rf __pycache__
	rm -rf sim_build
	rm -f *.vcd *.xml *.log
	rm -f results.xml

# Help target
help:
	@echo "CocoTB GA Coprocessor Simulation"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  make              - Run default test (complete GA flow)"
	@echo "  make test-basic   - Run basic functionality test"
	@echo "  make test-ga      - Run complete GA test"
	@echo "  make test-axi     - Run AXI protocol test"
	@echo "  make test-all     - Run all tests"
	@echo "  make waves        - Open waveform viewer"
	@echo "  make clean        - Clean generated files"
	@echo ""
	@echo "Options:"
	@echo "  SIM=icarus        - Use Icarus Verilog (default)"
	@echo "  SIM=verilator     - Use Verilator"
	@echo "  WAVES=1           - Generate waveforms (default)"
	@echo "  RANDOM_SEED=N     - Set random seed"
	@echo ""
	@echo "Examples:"
	@echo "  make SIM=icarus WAVES=1"
	@echo "  make test-basic"
	@echo "  make waves"