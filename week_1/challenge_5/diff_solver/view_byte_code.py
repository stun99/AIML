import marshal
import io
output_file = "euler_bytecode.txt"
with open("__pycache__/diff_eq.cpython-312.pyc", "rb") as f:
    f.read(16)  # Skip the header
    code = marshal.load(f)

import dis
dis.dis(code)

# Capture dis output
buffer = io.StringIO()
dis.dis(code, file=buffer)

# Save to file
with open(output_file, "w") as out_file:
    out_file.write(buffer.getvalue())

print(f"Bytecode written to: {output_file}")
