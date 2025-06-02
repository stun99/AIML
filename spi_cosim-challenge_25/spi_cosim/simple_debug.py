import cocotb 
from cocotb.triggers import Timer 
 
@cocotb.test() 
async def debug_test(dut): 
    """Simple debug test""" 
    print("?? COCOTB TEST IS ACTUALLY RUNNING!") 
    print("?? DUT signals:") 
    try: 
        print(f"  sclk: {dut.sclk}") 
        print(f"  mosi: {dut.mosi}") 
        print(f"  miso: {dut.miso}") 
        print(f"  cs_n: {dut.cs_n}") 
        dut.sclk.value = 0 
        print("? Successfully wrote to sclk") 
        await Timer(10, units="ns") 
        print("? Timer worked") 
        print("?? COCOTB + ICARUS WORKING!") 
    except Exception as e: 
        print(f"? DUT access failed: {e}") 
