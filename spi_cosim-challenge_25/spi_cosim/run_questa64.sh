#!/bin/bash

echo "======================================================"
echo "? Cocotb + QuestaSim 64-bit (Bash)"
echo "======================================================"

# Clean environment
unset COCOTB_RESOLVE_X

# Set cocotb environment
export MODULE=test_spi
export TOPLEVEL=spi_slave
export SIM=questa
export VERILOG_SOURCES=spi_slave.v
export COCOTB_LOG_LEVEL=INFO

echo "? Environment Setup:"
echo "   MODULE: $MODULE"
echo "   TOPLEVEL: $TOPLEVEL"
echo "   SIM: $SIM"
echo "   VERILOG_SOURCES: $VERILOG_SOURCES"
echo ""

echo "? Testing QuestaSim availability..."
if command -v vsim &> /dev/null; then
    echo "? QuestaSim found and working"
    vsim -version | head -1
else
    echo "? QuestaSim not found in PATH"
    exit 1
fi

echo ""
echo "? Starting QuestaSim + Cocotb simulation..."
echo "======================================================"

python -m cocotb.regression

echo ""
echo "======================================================"
echo "? Simulation Complete!"
echo "? Check QuestaSim transcript and waveforms"
echo "? Look for .wlf files for waveform viewing"
echo "======================================================"
