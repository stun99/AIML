import numpy as np

# Activation functions
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def sigmoid_derivative(x):
    return x * (1 - x)

# 4 input combinations for 2-input logic gates
X = np.array([
    [0, 0],
    [0, 1],
    [1, 0],
    [1, 1]
])

# Truth tables
Y_NAND = np.array([[1], [1], [1], [0]])  # NAND
Y_XOR = np.array([[0], [1], [1], [0]])   # XOR

# Train function for a 2-layer neural network
def train_gate(X, y, hidden_size=4, epochs=20000, lr=0.05):
    np.random.seed(42)
    input_size = X.shape[1]
    output_size = 1

    # Weight and bias initialization
    W1 = np.random.randn(input_size, hidden_size)
    b1 = np.zeros((1, hidden_size))
    W2 = np.random.randn(hidden_size, output_size)
    b2 = np.zeros((1, output_size))

    # Training loop
    for epoch in range(epochs):
        # Forward pass
        hidden_input = np.dot(X, W1) + b1
        hidden_output = sigmoid(hidden_input)
        final_input = np.dot(hidden_output, W2) + b2
        final_output = sigmoid(final_input)

        # Backward pass
        error = y - final_output
        d_output = error * sigmoid_derivative(final_output)
        error_hidden = d_output.dot(W2.T)
        d_hidden = error_hidden * sigmoid_derivative(hidden_output)

        # Update weights and biases
        W2 += hidden_output.T.dot(d_output) * lr
        b2 += np.sum(d_output, axis=0, keepdims=True) * lr
        W1 += X.T.dot(d_hidden) * lr
        b1 += np.sum(d_hidden, axis=0, keepdims=True) * lr

    return W1, b1, W2, b2

# Predict function
def predict_gate(X, W1, b1, W2, b2):
    hidden = sigmoid(np.dot(X, W1) + b1)
    output = sigmoid(np.dot(hidden, W2) + b2)
    return np.round(output), output

# --- NAND ---
print("Predictions after training for NAND:")
W1_nand, b1_nand, W2_nand, b2_nand = train_gate(X, Y_NAND)
y_pred_nand, y_raw_nand = predict_gate(X, W1_nand, b1_nand, W2_nand, b2_nand)
for i in range(len(X)):
    print(f"Input: {X[i]}, Predicted: {int(y_pred_nand[i][0])}, Raw: {y_raw_nand[i][0]:.4f}")

print("\n" + "-"*50 + "\n")

# --- XOR ---
print("Predictions after training for XOR:")
W1_xor, b1_xor, W2_xor, b2_xor = train_gate(X, Y_XOR)
y_pred_xor, y_raw_xor = predict_gate(X, W1_xor, b1_xor, W2_xor, b2_xor)
for i in range(len(X)):
    print(f"Input: {X[i]}, Predicted: {int(y_pred_xor[i][0])}, Raw: {y_raw_xor[i][0]:.4f}")
