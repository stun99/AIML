# Makefile for GA Coprocessor Cocotb Testing with QuestaSim
TOPLEVEL_LANG = verilog
SIM = questa

# Top level module
TOPLEVEL := ga_coprocessor

# Python test module
MODULE := test_ga_enhanced

# Verilog source files
VERILOG_SOURCES := ga_coprocessor.v

# QuestaSim specific settings
COMPILE_ARGS += +define+COCOTB_SIM=1
SIM_ARGS += -voptargs="+acc"
SIM_ARGS += -t 1ns

# Enable waveform generation (optional)
# SIM_ARGS += -do "log -r /*; run -all"

# Cocotb makefiles
include $(shell cocotb-config --makefiles)/Makefile.sim

# Additional targets for specific tests
test_performance:
	$(MAKE) MODULE=test_ga_enhanced TESTCASE=test_performance_comparison

test_operations:
	$(MAKE) MODULE=test_ga_enhanced TESTCASE=test_hardware_operations

test_ga:
	$(MAKE) MODULE=test_ga_enhanced TESTCASE=test_enhanced_ga_hardware

test_all:
	$(MAKE) MODULE=test_ga_enhanced


# Help target
help:
	@echo "Available targets:"
	@echo "  test_performance  - Run hardware vs software performance comparison"
	@echo "  test_operations   - Run individual hardware operation tests"
	@echo "  test_ga          - Run complete genetic algorithm test"
	@echo "  test_all         - Run all tests"
	@echo "  clean            - Clean build artifacts"
	@echo ""
	@echo "Simulator options (set SIM=):"
	@echo "  icarus    - Icarus Verilog (default, free)"
	@echo "  verilator - Verilator (free, faster)"
	@echo "  questa    - Mentor Questa/ModelSim (commercial)"
	@echo "  vcs       - Synopsys VCS (commercial)"
	@echo ""
	@echo "Example usage:"
	@echo "  make test_performance"
	@echo "  make test_all SIM=verilator"

.PHONY: test_performance test_operations test_ga test_all clean help
