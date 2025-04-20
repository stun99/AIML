import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, PillowWriter

# Training data for 2-input NAND gate
X = np.array([[0, 0],
              [0, 1],
              [1, 0],
              [1, 1]])
y = np.array([1, 1, 1, 0])  # NAND outputs for the above inputs

# Add a bias term (1) to each input vector
X_aug = np.hstack([np.ones((X.shape[0], 1)), X])

# Initialize weights (w0 = bias, w1, w2) to small random values
np.random.seed(2)  # for reproducibility (can remove for random initial weights)
w = np.random.randn(X_aug.shape[1]) * 0.5

# Sigmoid activation function
def sigmoid(z):
    return 1 / (1 + np.exp(-z))

# Setup Matplotlib figure and axis
fig, ax = plt.subplots()
ax.set_xlim(-0.5, 1.5)
ax.set_ylim(-0.5, 1.5)
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_title('Perceptron Learning for NAND Gate')

# Plot the data points: output 1 in blue circles, output 0 in red squares
class1 = X[y == 1]
class0 = X[y == 0]
ax.scatter(class1[:, 0], class1[:, 1], color='blue', marker='o', label='Output = 1')
ax.scatter(class0[:, 0], class0[:, 1], color='red', marker='s', label='Output = 0')
ax.legend(loc='upper right')

# Initialize an empty line for the decision boundary
line, = ax.plot([], [], 'k--', linewidth=2)

# Learning parameters
learning_rate = 0.7            # step size for weight updates
num_frames = 75                # number of updates/frames in the animation
current_index = 0              # index of current training sample
misclassifications = 0         # counter for misclassified samples in current epoch
training_converged = False     # flag to indicate convergence (all points classified correctly)

# Initialization function for the animation (clears the decision boundary line)
def init():
    line.set_data([], [])
    return line,

# Animation update function – runs on each frame
def update(frame):
    global w, current_index, misclassifications, training_converged
    if training_converged:
        # If already converged, no further weight updates; keep the line as is
        return line,
    # Start a new epoch, reset misclassification count
    if current_index == 0:
        misclassifications = 0
    # Take the next training sample
    xi = X_aug[current_index]
    yi = y[current_index]
    # Compute perceptron output using sigmoid activation
    net = np.dot(w, xi)               # w · x (linear combination)
    output = sigmoid(net)             # sigmoid activation
    pred_class = 1 if output >= 0.5 else 0  # predicted class (threshold at 0.5)
    # Check if misclassified
    if pred_class != yi:
        misclassifications += 1
    # Perceptron weight update (delta rule with sigmoid)
    error = yi - output
    w = w + learning_rate * error * output * (1 - output) * xi
    # Update the decision boundary line based on new weights
    if abs(w[2]) > 1e-6:
        # Compute two points for the line (at x1 limits)
        x_vals = np.linspace(-0.5, 1.5, 100)
        y_vals = -(w[0] + w[1] * x_vals) / w[2]
    else:
        # If w[2] is ~0, draw a vertical line at x = -w0/w1
        x_vals = np.array([-w[0] / w[1]] * 2)
        y_vals = np.array([-0.5, 1.5])
    line.set_data(x_vals, y_vals)
    # Move to the next sample (cyclically)
    current_index = (current_index + 1) % X_aug.shape[0]
    # If one full pass (epoch) is done and no misclassifications, training has converged
    if current_index == 0 and misclassifications == 0:
        training_converged = True
    return line,

# Create the animation
anim = FuncAnimation(fig, update, frames=num_frames, init_func=init, blit=True, interval=200)

# Save the animation as a GIF file
anim.save('nand_perceptron_training.gif', writer=PillowWriter(fps=5))
# (Alternatively, use plt.show() to display the animation in an interactive environment)
