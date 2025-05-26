import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

@cocotb.test()
async def spi_test(dut):
    """SPI test with ModelSim"""
    print("=== Starting SPI Test ===")
    
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    # Initialize
    dut.cs_n.value = 1
    dut.mosi.value = 0
    await Timer(100, units="ns")
    
    # SPI transaction
    dut.cs_n.value = 0
    await Timer(20, units="ns")
    
    for i in range(8):
        bit = (0x55 >> (7-i)) & 1
        dut.mosi.value = bit
        await RisingEdge(dut.clk)
        
    dut.cs_n.value = 1
    await Timer(100, units="ns")
    
    print("=== SPI Test Completed Successfully! ===")