import os 
import sys 
 
print("?? COCOTB DEBUG TEST") 
print("=" * 40) 
 
# Set environment 
os.environ['PATH'] = r'C:\iverilog\bin;' + os.environ.get('PATH', '') 
if 'COCOTB_RESOLVE_X' in os.environ: del os.environ['COCOTB_RESOLVE_X'] 
os.environ['MODULE'] = 'spi_test' 
os.environ['TOPLEVEL'] = 'spi_slave' 
os.environ['SIM'] = 'icarus' 
os.environ['VERILOG_SOURCES'] = 'spi_slave.v' 
os.environ['COCOTB_LOG_LEVEL'] = 'DEBUG' 
 
print("? Environment variables set") 
 
# Check files exist 
import os.path 
print(f"?? spi_slave.v exists: {os.path.exists('spi_slave.v')}") 
print(f"?? spi_test.py exists: {os.path.exists('spi_test.py')}") 
 
# Test import 
try: 
    import spi_test 
    print("? spi_test.py imported successfully") 
    print(f"?? Functions found: {[f for f in dir(spi_test) if not f.startswith('_')]}") 
except Exception as e: 
    print(f"? Import failed: {e}") 
 
print("?? Starting cocotb regression...") 
import subprocess 
result = subprocess.run([sys.executable, '-m', 'cocotb.regression'], capture_output=False) 
print(f"?? Cocotb finished with return code: {result.returncode}") 
