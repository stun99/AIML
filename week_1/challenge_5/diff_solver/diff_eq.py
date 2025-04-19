# euler_solver.py
import numpy as np
import matplotlib.pyplot as plt
import py_compile

def dydt(t, y):
    return -2*y + 1

# Initial conditions
y0 = 0
t0 = 0
t_end = 5
h = 0.1  # step size

# Time points
t_values = np.arange(t0, t_end + h, h)
y_values = np.zeros(len(t_values))
y_values[0] = y0

# Euler loop
for i in range(1, len(t_values)):
    y_values[i] = y_values[i-1] + h * dydt(t_values[i-1], y_values[i-1])

# Plotting
plt.plot(t_values, y_values, label="Euler Approximation")
plt.xlabel("t")
plt.ylabel("y(t)")
plt.title("ODE Solution using Euler Method")
plt.grid(True)
plt.legend()
plt.show()
