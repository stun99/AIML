import numpy as np

# XOR input and target output
X = np.array([[0, 0],
              [0, 1],
              [1, 0],
              [1, 1]])

y = np.array([[0],
              [1],
              [1],
              [0]])

# Sigmoid activation and derivative
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def sigmoid_derivative(x):
    return x * (1 - x)

# Initialize network parameters
np.random.seed(1)
input_neurons = 2
hidden_neurons = 2
output_neurons = 1
lr = 0.5
epochs = 10000

# Random initialization of weights and biases
W1 = np.random.uniform(-1, 1, (input_neurons, hidden_neurons))
b1 = np.zeros((1, hidden_neurons))

W2 = np.random.uniform(-1, 1, (hidden_neurons, output_neurons))
b2 = np.zeros((1, output_neurons))

# Training using Backpropagation
for epoch in range(epochs):
    # --- Forward pass ---
    z1 = np.dot(X, W1) + b1
    a1 = sigmoid(z1)

    z2 = np.dot(a1, W2) + b2
    a2 = sigmoid(z2)

    # --- Compute Loss (Mean Squared Error) ---
    loss = np.mean((y - a2) ** 2)

    # --- Backward pass ---
    d_a2 = (y - a2) * sigmoid_derivative(a2)
    d_W2 = np.dot(a1.T, d_a2)
    d_b2 = np.sum(d_a2, axis=0, keepdims=True)

    d_a1 = np.dot(d_a2, W2.T) * sigmoid_derivative(a1)
    d_W1 = np.dot(X.T, d_a1)
    d_b1 = np.sum(d_a1, axis=0, keepdims=True)

    # --- Update weights and biases ---
    W2 += lr * d_W2
    b2 += lr * d_b2
    W1 += lr * d_W1
    b1 += lr * d_b1

    if epoch % 1000 == 0:
        print(f"Epoch {epoch} — Loss: {loss:.4f}")

# Final prediction
print("\nTrained XOR Output:")
print(np.round(a2, 3))
