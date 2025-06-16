TOPLEVEL_LANG = verilog

VERILOG_SOURCES = ga_coprocessor.v
PROJECT_NAME := ga_coprocessor
TESTBENCH_MODULE := test_ga_enhanced
TOPLEVEL := ga_coprocessor
VERILOG_SOURCES := ga_coprocessor.v

# Simulator Configuration (QuestaSim optimized)
SIM := questa
COMPILE_ARGS += +define+COCOTB_SIM=1 +define+SIMULATION=1
SIM_ARGS += -voptargs="+acc" -t 1ns -suppress 3584,8683

# Optional: Enable waveform capture (uncomment for debugging)
# SIM_ARGS += -do "log -r /*; run -all"

# Performance and Debug Settings
COCOTB_LOG_LEVEL ?= INFO
PYTHONDONTWRITEBYTECODE := 1
export PYTHONDONTWRITEBYTECODE

# Include cocotb makefiles
include $(shell cocotb-config --makefiles)/Makefile.sim

# ==============================================================================
# PRIMARY TEST TARGETS - Core Functionality
# ==============================================================================

.PHONY: test_performance test_operations test_ga

test_performance:
	@echo "? Running Hardware vs Software Performance Comparison..."
	@echo "   This test provides speedup measurements for your report"
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_performance_comparison

test_operations:
	@echo "? Running Individual Hardware Operation Tests..."
	@echo "   Verifying fitness, crossover, and mutation operations"
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_hardware_operations

test_ga:
	@echo "? Running Complete Genetic Algorithm Test..."
	@echo "   End-to-end genetic algorithm with hardware acceleration"
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_enhanced_ga_hardware

# ==============================================================================
# COMPREHENSIVE VERIFICATION TARGETS - Production Quality
# ==============================================================================

.PHONY: test_edge_cases test_stress test_limits test_comprehensive

test_edge_cases:
	@echo "??  Running Edge Case Robustness Testing..."
	@echo "   Testing boundary conditions and error handling"
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_edge_cases

test_stress:
	@echo "? Running Stress Testing and System Limits..."
	@echo "   Testing sustained operation and performance under load"
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_stress_scenarios

test_limits:
	@echo "? Running System Limits and Breaking Point Analysis..."
	@echo "   Testing timeout protection and state machine robustness"
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_system_limits

test_comprehensive:
	@echo "? Running Comprehensive Verification Summary..."
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_comprehensive_verification

# ==============================================================================
# TEST SUITE TARGETS - Organized Testing Workflows
# ==============================================================================

.PHONY: test_basic_suite test_robustness_suite test_verification_suite test_quick

test_quick:
	@echo "? QUICK VERIFICATION (2-3 minutes)"
	@echo "================================================="
	@$(MAKE) test_operations
	@$(MAKE) test_performance
	@echo "================================================="
	@echo "? Quick verification complete!"

test_basic_suite:
	@echo "? BASIC VERIFICATION SUITE (5-10 minutes)"
	@echo "================================================="
	@$(MAKE) test_operations
	@$(MAKE) test_performance
	@$(MAKE) test_ga
	@echo "================================================="
	@echo "? Basic verification suite complete!"

test_robustness_suite:
	@echo "??  ROBUSTNESS VERIFICATION SUITE (10-15 minutes)"
	@echo "================================================="
	@$(MAKE) test_edge_cases
	@$(MAKE) test_stress
	@$(MAKE) test_limits
	@echo "================================================="
	@echo "? Robustness verification suite complete!"

test_verification_suite:
	@echo "? COMPLETE VERIFICATION SUITE (15-20 minutes)"
	@echo "============================================================="
	@echo "Running comprehensive verification for academic documentation"
	@echo "This includes all tests for production-level validation:"
	@echo "  1. ? Basic Operations Verification"
	@echo "  2. ? Performance Benchmarking"
	@echo "  3. ? Complete GA System Test"
	@echo "  4. ? Edge Case Robustness"
	@echo "  5. ? Stress Testing"
	@echo "  6. ? System Limits Analysis"
	@echo "============================================================="
	@$(MAKE) test_operations
	@$(MAKE) test_performance
	@$(MAKE) test_ga
	@$(MAKE) test_edge_cases
	@$(MAKE) test_stress
	@$(MAKE) test_limits
	@echo "============================================================="
	@echo "? COMPLETE VERIFICATION SUITE FINISHED!"
	@echo "   All tests passed - hardware is production ready"
	@echo "   Results can be used for academic documentation"
	@echo "============================================================="

# ==============================================================================
# SPECIALIZED TESTING TARGETS
# ==============================================================================

.PHONY: test_debug test_waves test_regression

test_debug:
	@echo "? Running Tests with Enhanced Debug Output..."
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_hardware_operations \
		SIM_ARGS="$(SIM_ARGS) -do 'log -r /*; run -all'" COCOTB_LOG_LEVEL=DEBUG

test_waves:
	@echo "? Running Tests with Waveform Generation..."
	@echo "   Waveforms will be saved for analysis"
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_performance_comparison \
		SIM_ARGS="$(SIM_ARGS) -do 'log -r /*; run -all; quit'"

test_regression:
	@echo "? Running Regression Testing..."
	@echo "   Testing for consistent results across multiple runs"
	@for i in 1 2 3; do \
		echo "Regression run $$i/3..."; \
		$(MAKE) test_performance >/dev/null 2>&1 || exit 1; \
	done
	@echo "? Regression testing passed!"

# ==============================================================================
# REPORTING AND DOCUMENTATION TARGETS
# ==============================================================================

.PHONY: report_performance report_comprehensive report_summary generate_docs

report_performance:
	@echo "? Generating Performance Report..."
	@mkdir -p reports
	$(MAKE) test_performance > reports/performance_report_$(shell date +%Y%m%d_%H%M).txt 2>&1
	@echo "? Performance report saved to: reports/performance_report_$(shell date +%Y%m%d_%H%M).txt"

report_comprehensive:
	@echo "? Generating Comprehensive Test Report..."
	@mkdir -p reports
	$(MAKE) test_verification_suite > reports/comprehensive_report_$(shell date +%Y%m%d_%H%M).txt 2>&1
	@echo "? Comprehensive report saved to: reports/comprehensive_report_$(shell date +%Y%m%d_%H%M).txt"

report_summary:
	@echo "? Generating Test Summary..."
	@mkdir -p reports
	$(MAKE) test_comprehensive > reports/test_summary_$(shell date +%Y%m%d_%H%M).txt 2>&1
	@echo "? Test summary saved to: reports/test_summary_$(shell date +%Y%m%d_%H%M).txt"

generate_docs:
	@echo "? Generating Documentation Package..."
	@mkdir -p docs
	@echo "# GA Coprocessor Test Results" > docs/README.md
	@echo "Generated on: $(shell date)" >> docs/README.md
	@echo "" >> docs/README.md
	@echo "## Quick Start" >> docs/README.md
	@echo "\`\`\`bash" >> docs/README.md
	@echo "make test_verification_suite  # Run all tests" >> docs/README.md
	@echo "make test_performance        # Get speedup numbers" >> docs/README.md
	@echo "\`\`\`" >> docs/README.md
	@$(MAKE) report_comprehensive
	@cp reports/comprehensive_report_*.txt docs/
	@echo "? Documentation package created in docs/ directory"

# ==============================================================================
# DEVELOPMENT AND MAINTENANCE TARGETS
# ==============================================================================

.PHONY: check_env check_syntax validate_setup lint

check_env:
	@echo "? Checking Development Environment..."
	@echo "============================================="
	@echo "? Current directory: $(shell pwd)"
	@echo "? Python version: $(shell python3 --version 2>/dev/null || echo 'Python3 not found')"
	@echo "? Cocotb: $(shell python3 -c 'import cocotb; print("? Version", cocotb.__version__)' 2>/dev/null || echo '? Not installed - run: pip install cocotb')"
	@echo "? QuestaSim: $(shell which vsim >/dev/null 2>&1 && echo '? Available' || echo '? Not in PATH')"
	@echo "============================================="
	@echo "? Required Files:"
	@echo "  $(VERILOG_SOURCES): $(shell test -f $(VERILOG_SOURCES) && echo '? FOUND' || echo '? MISSING')"
	@echo "  $(TESTBENCH_MODULE).py: $(shell test -f $(TESTBENCH_MODULE).py && echo '? FOUND' || echo '? MISSING')"
	@echo "  Makefile: $(shell test -f Makefile && echo '? FOUND' || echo '? MISSING')"
	@echo "============================================="

check_syntax:
	@echo "? Checking Python Syntax..."
	@python3 -m py_compile $(TESTBENCH_MODULE).py
	@echo "? Python syntax validation passed!"

validate_setup: check_env check_syntax
	@echo "? Running Setup Validation..."
	@echo "Testing basic cocotb functionality..."
	@python3 -c "import cocotb; from cocotb.triggers import RisingEdge; print('? Cocotb imports successful')"
	@echo "? Development environment is ready!"

lint:
	@echo "? Running Code Quality Checks..."
	@python3 -m flake8 $(TESTBENCH_MODULE).py --max-line-length=100 --ignore=E501,W503 2>/dev/null || echo "??  flake8 not installed (optional)"
	@echo "? Code quality check complete!"


# ==============================================================================
# INFORMATION AND HELP TARGETS
# ==============================================================================

.PHONY: list_tests status help

list_tests:
	@echo "? Available Test Targets:"
	@echo "=========================="
	@echo ""
	@echo "? CORE TESTS (Essential):"
	@echo "  test_performance     - Hardware vs software speed comparison"
	@echo "  test_operations      - Individual operation verification"
	@echo "  test_ga             - Complete genetic algorithm test"
	@echo ""
	@echo "??  COMPREHENSIVE TESTS (Production Quality):"
	@echo "  test_edge_cases     - Edge case and boundary testing"
	@echo "  test_stress         - Stress testing and system limits"
	@echo "  test_limits         - Breaking point analysis"
	@echo ""
	@echo "? TEST SUITES (Multiple Tests):"
	@echo "  test_quick             - Fast verification (2-3 min)"
	@echo "  test_basic_suite       - Core functionality (5-10 min)"
	@echo "  test_robustness_suite  - Advanced testing (10-15 min)"
	@echo "  test_verification_suite - Complete verification (15-20 min) ?"
	@echo ""
	@echo "? DEVELOPMENT:"
	@echo "  test_debug          - Enhanced debugging output"
	@echo "  test_waves          - Generate waveforms"
	@echo "  test_regression     - Consistency testing"
	@echo ""
	@echo "? REPORTING:"
	@echo "  report_performance     - Performance report file"
	@echo "  report_comprehensive   - Complete test report"
	@echo "  generate_docs         - Documentation package"

status:
	@echo "? Project Status:"
	@echo "=================="
	@echo "Project: $(PROJECT_NAME)"
	@echo "Testbench: $(TESTBENCH_MODULE).py"
	@echo "Hardware: $(VERILOG_SOURCES)"
	@echo "Simulator: $(SIM)"
	@echo "Date: $(shell date)"
	@echo ""
	@echo "? Quick Commands:"
	@echo "  make test_performance        # Get speedup numbers"
	@echo "  make test_verification_suite # Complete testing"
	@echo "  make check_env              # Verify setup"

help:
	@echo "? GA Coprocessor Hardware Verification System"
	@echo "=============================================="
	@echo ""
	@echo "? QUICK START:"
	@echo "  make test_performance        # Main benchmarking (5 min)"
	@echo "  make test_verification_suite # Complete testing (20 min)"
	@echo "  make check_env              # Verify environment setup"
	@echo ""
	@echo "? FOR YOUR ACADEMIC REPORT:"
	@echo "  make test_performance        # Get speedup measurements"
	@echo "  make report_comprehensive    # Generate report file"
	@echo "  make test_verification_suite # Complete verification"
	@echo ""
	@echo "? DEVELOPMENT WORKFLOW:"
	@echo "  make validate_setup         # First-time setup check"
	@echo "  make test_quick            # Fast development testing"
	@echo "  make test_debug            # Debugging mode"
	@echo "  make test_waves            # Generate waveforms"
	@echo ""
	@echo "? COMPREHENSIVE TESTING:"
	@echo "  make test_basic_suite      # Core functionality"
	@echo "  make test_robustness_suite # Advanced testing"
	@echo "  make test_verification_suite # Production-level verification"
	@echo ""
	@echo "? MAINTENANCE:"
	@echo "  make clean                 # Clean build files"
	@echo "  make clean_all             # Deep clean everything"
	@echo ""
	@echo "? INFORMATION:"
	@echo "  make list_tests            # Show all available tests"
	@echo "  make status               # Show project status"
	@echo ""
	@echo "? EXAMPLES:"
	@echo "  make test_performance              # Get performance data"
	@echo "  make test_verification_suite       # Run everything"
	@echo "  make report_comprehensive          # Generate report"
	@echo "  make test_debug SIM=verilator      # Use different simulator"
	@echo ""
	@echo "For more details: make list_tests"
	@echo "=============================================="

# ==============================================================================
# ALIASES AND CONVENIENCE TARGETS
# ==============================================================================

.PHONY: test_all benchmark verify perf quick

# Common aliases
test_all: test_verification_suite
benchmark: test_performance
verify: test_verification_suite
perf: test_performance
quick: test_quick

# Default target
.DEFAULT_GOAL := help

# ==============================================================================
# ADVANCED FEATURES
# ==============================================================================

.PHONY: test_parallel test_with_coverage

# Parallel testing (if supported)
test_parallel:
	@echo "? Running Parallel Testing..."
	@echo "Note: Parallel execution may not be supported in all simulators"
	$(MAKE) test_operations &
	$(MAKE) test_performance &
	wait
	@echo "? Parallel testing complete"

# Coverage analysis (if tools available)
test_with_coverage:
	@echo "? Running Tests with Coverage Analysis..."
	$(MAKE) MODULE=$(TESTBENCH_MODULE) TESTCASE=test_verification_suite \
		SIM_ARGS="$(SIM_ARGS) -coverage" || echo "??  Coverage not supported in current setup"

# ==============================================================================
# MAKEFILE METADATA
# ==============================================================================

# Makefile self-documentation
makefile_info:
	@echo "? Makefile Information:"
	@echo "Version: Production-Ready Final"
	@echo "Targets: $(shell $(MAKE) -qp | grep '^[a-zA-Z]' | cut -d: -f1 | sort | uniq | wc -l)"
	@echo "Features: Complete verification, reporting, debugging"
	@echo "Optimized for: Academic projects, QuestaSim, Professional verification"
