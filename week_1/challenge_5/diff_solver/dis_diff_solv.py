# disassemble_euler.py
import dis
import diff_eq

print("=== Disassembled Bytecode for euler_solver ===")
dis.dis(diff_eq)
