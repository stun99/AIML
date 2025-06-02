# Simple Makefile for GA Hardware-Software Co-Design Project
# Matches exact project structure

# Configuration
SIM ?= icarus
WAVES ?= 1

# Hardware files
HW_FILES = hardware/ga_coprocessor.v \
           hardware/ga_processing_core.v \
           hardware/fitness_calculator.v \
           hardware/axi4_lite_slave.v \
           hardware/lfsr_32bit.v

# Software files
SW_FILES = software/ga_controller.py

# Verification files
VERIF_FILES = verification/test_ga_coprocessor.py

# Default target
all: build

# Build and test everything
build:
	@echo "Building GA Hardware-Software Co-Design..."
	@make check
	@make sim
	@make sw
	@echo "Build completed successfully!"

# Check if all files exist
check:
	@echo "Checking project files..."
	@for file in $(HW_FILES) $(SW_FILES) $(VERIF_FILES); do \
		if [ ! -f $$file ]; then \
			echo "ERROR: Missing file $$file"; \
			exit 1; \
		fi; \
	done
	@echo "All files present ✓"

# Run hardware simulation
sim:
	@echo "Running hardware simulation..."
	@cd verification && make -f ../verification.mk sim

# Run software demo
sw:
	@echo "Running software demo..."
	@cd software && python3 ga_controller.py

# View waveforms
waves:
	@echo "Opening waveform viewer..."
	@cd verification && gtkwave dump.vcd &

# Clean build artifacts  
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf verification/__pycache__
	@rm -rf verification/sim_build
	@rm -f verification/*.vcd
	@rm -f verification/*.xml
	@rm -f verification/*.log
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Help
help:
	@echo "GA Hardware-Software Co-Design Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all, build  - Build and test everything (default)"
	@echo "  sim         - Run hardware simulation"
	@echo "  sw          - Run software demo"
	@echo "  waves       - View waveforms"
	@echo "  check       - Check all files exist"
	@echo "  clean       - Clean build artifacts"
	@echo "  help        - Show this help"
	@echo ""
	@echo "Options:"
	@echo "  SIM=icarus  - Simulator (icarus/verilator)"
	@echo "  WAVES=1     - Generate waveforms (1/0)"

.PHONY: all build sim sw waves check clean help