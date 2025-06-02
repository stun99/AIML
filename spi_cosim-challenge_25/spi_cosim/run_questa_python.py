import os
import sys

def main():
    # Clean environment
    if 'COCOTB_RESOLVE_X' in os.environ:
        del os.environ['COCOTB_RESOLVE_X']
    
    print("=" * 60)
    print("? Cocotb + QuestaSim 64-bit (Python)")
    print("=" * 60)
    
    try:
        from cocotb.runner import get_runner
        print("? Cocotb runner imported successfully")
        
        runner = get_runner("questa")
        print("? QuestaSim 64-bit runner created")
        
        print("? Building simulation...")
        runner.build(
            verilog_sources=["spi_slave.v"],
            hdl_toplevel="spi_slave",
            build_dir="sim_build"
        )
        print("? Build complete")
        
        print("? Running test...")
        runner.test(
            hdl_toplevel="spi_slave",
            test_module="test_spi"
        )
        print("? Test complete successfully!")
        
    except Exception as e:
        print(f"? Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
