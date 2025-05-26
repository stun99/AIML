import os 
import subprocess 
import sys 
 
# Clean environment 
env = os.environ.copy() 
if 'COCOTB_RESOLVE_X' in env: 
    del env['COCOTB_RESOLVE_X'] 
 
env['MODULE'] = 'test_spi' 
env['TOPLEVEL'] = 'spi_slave' 
env['SIM'] = 'questa' 
env['VERILOG_SOURCES'] = 'rtl/spi_slave.v' 
env['PYTHONPATH'] = 'tb' 
 
print("Starting fresh cocotb process...") 
result = subprocess.run([sys.executable, '-m', 'cocotb.regression'], env=env) 
print(f"Simulation completed with return code: {result.returncode}") 
