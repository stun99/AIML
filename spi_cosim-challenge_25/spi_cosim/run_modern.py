import os
import sys
from pathlib import Path

def main():
    # Clean environment
    if 'COCOTB_RESOLVE_X' in os.environ:
        del os.environ['COCOTB_RESOLVE_X']
    
    print("=" * 60)
    print("?? Modern Cocotb + ModelSim Runner")
    print("=" * 60)
    
    try:
        from cocotb.runner import get_runner
        print("? Cocotb runner imported successfully")
        
        # Configure the runner
        runner = get_runner("questa")
        print("? ModelSim runner created")
        
        # Build the simulation
        print("?? Building simulation...")
        runner.build(
            verilog_sources=["spi_slave.v"],
            hdl_toplevel="spi_slave",
            build_dir="sim_build"
        )
        print("? Build complete")
        
        # Run the test
        print("?? Running test...")
        runner.test(
            hdl_toplevel="spi_slave",
            test_module="test_spi"
        )
        print("? Test complete")
        
    except Exception as e:
        print(f"? Error: {e}")
        print("Trying fallback method...")
        
        # Fallback to direct approach
        os.environ['MODULE'] = 'test_spi'
        os.environ['TOPLEVEL'] = 'spi_slave'
        os.environ['SIM'] = 'questa'
        os.environ['VERILOG_SOURCES'] = 'spi_slave.v'
        
        import subprocess
        result = subprocess.run([sys.executable, '-m', 'cocotb.regression'])
        print(f"Fallback result: {result.returncode}")

if __name__ == "__main__":
    main()
    input("Press Enter to continue...")