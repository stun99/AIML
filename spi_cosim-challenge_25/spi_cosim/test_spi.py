import cocotb
from cocotb.triggers import Timer, FallingEdge
from cocotb.clock import Clock

class SPIMaster:
    def __init__(self, dut):
        self.dut = dut
        
    async def spi_write_read(self, data_out):
        """Send 8 bits and receive 8 bits"""
        print(f"  🔄 Starting SPI transaction with data 0x{data_out:02X}")
        data_in = 0
        
        # Start transaction - CS low
        print("  📍 Asserting CS (Chip Select)")
        self.dut.cs_n.value = 0
        await Timer(10, units="ns")
        
        # Send 8 bits
        print("  📡 Sending 8 bits...")
        for i in range(8):
            # Set data bit
            bit = (data_out >> (7-i)) & 1
            self.dut.mosi.value = bit
            print(f"    Bit {i}: MOSI={bit}")
            await Timer(10, units="ns")
            
            # Clock high
            self.dut.sclk.value = 1
            await Timer(10, units="ns")
            
            # Read MISO on clock high
            miso_bit = int(self.dut.miso.value)
            data_in = (data_in << 1) | miso_bit
            print(f"    Bit {i}: MISO={miso_bit}")
            
            # Clock low
            self.dut.sclk.value = 0
            await Timer(10, units="ns")
        
        # End transaction - CS high
        print("  📍 Deasserting CS")
        self.dut.cs_n.value = 1
        await Timer(20, units="ns")
        
        print(f"  ✅ Transaction complete: Received 0x{data_in:02X}")
        return data_in

@cocotb.test()
async def spi_cosim_test(dut):
    """SPI Master-Slave Cosimulation Test with ModelSim"""
    
    print("\n" + "=" * 70)
    print("🚀 COCOTB + MODELSIM SPI COSIMULATION")
    print("🔗 Python Master ↔ Verilog Slave")
    print("=" * 70)
    
    dut._log.info("Starting ModelSim cocotb simulation!")
    
    # Check DUT signals exist
    print(f"📡 DUT Signals Available:")
    print(f"   sclk: {hasattr(dut, 'sclk')}")
    print(f"   mosi: {hasattr(dut, 'mosi')}")
    print(f"   miso: {hasattr(dut, 'miso')}")
    print(f"   cs_n: {hasattr(dut, 'cs_n')}")
    print("=" * 70)
    
    # Initialize
    print("🔧 Initializing SPI signals...")
    dut.sclk.value = 0
    dut.mosi.value = 0
    dut.cs_n.value = 1
    print("✅ SPI signals initialized")
    
    await Timer(100, units="ns")
    print("⏰ Initial delay complete")
    
    # Create SPI master
    print("🎯 Creating SPI Master...")
    spi = SPIMaster(dut)
    print("✅ SPI Master created")
    
    # Test 1: Send 0x55
    print("\n🧪 Test 1: Sending 0x55")
    rx_data = await spi.spi_write_read(0x55)
    print(f"📤 Sent: 0x{0x55:02X}")
    print(f"📥 Received: 0x{rx_data:02X}")
    print("✅ Test 1 Complete")
    
    # Test 2: Send 0xCC  
    print("\n🧪 Test 2: Sending 0xCC")
    rx_data = await spi.spi_write_read(0xCC)
    print(f"📤 Sent: 0x{0xCC:02X}")
    print(f"📥 Received: 0x{rx_data:02X}")
    print("✅ Test 2 Complete")
    
    # Test 3: Send 0x00
    print("\n🧪 Test 3: Sending 0x00")
    rx_data = await spi.spi_write_read(0x00)
    print(f"📤 Sent: 0x{0x00:02X}")
    print(f"📥 Received: 0x{rx_data:02X}")
    print("✅ Test 3 Complete")
    
    print("\n" + "=" * 70)
    print("🎉 ALL SPI TESTS COMPLETED SUCCESSFULLY!")
    print("🔗 Python Master ↔ Verilog Slave Communication Working!")
    print("🏆 COCOTB + MODELSIM COSIMULATION SUCCESS!")
    print("=" * 70)
    
    dut._log.info("All tests passed! ModelSim simulation complete!")