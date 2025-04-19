import numpy as np

# Activation functions
def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def sigmoid_derivative(x):
    return x * (1 - x)

# Input combinations
X = np.array([
    [0, 0],
    [0, 1],
    [1, 0],
    [1, 1]
])

# Target outputs
Y_NAND = np.array([[1], [1], [1], [0]])
Y_XOR  = np.array([[0], [1], [1], [0]])

# 2-layer MLP training function
def train_gate(X, y, hidden_size=4, epochs=20000, lr=0.05):
    np.random.seed(42)
    input_size = X.shape[1]
    output_size = 1

    # Xavier initialization
    W1 = np.random.randn(input_size, hidden_size) * np.sqrt(1. / input_size)
    b1 = np.zeros((1, hidden_size))
    W2 = np.random.randn(hidden_size, output_size) * np.sqrt(1. / hidden_size)
    b2 = np.zeros((1, output_size))

    for epoch in range(epochs):
        # Forward
        z1 = np.dot(X, W1) + b1
        a1 = sigmoid(z1)
        z2 = np.dot(a1, W2) + b2
        a2 = sigmoid(z2)

        # Backward
        error = y - a2
        d2 = error * sigmoid_derivative(a2)
        d1 = d2.dot(W2.T) * sigmoid_derivative(a1)

        # Weight updates
        W2 += a1.T.dot(d2) * lr
        b2 += np.sum(d2, axis=0, keepdims=True) * lr
        W1 += X.T.dot(d1) * lr
        b1 += np.sum(d1, axis=0, keepdims=True) * lr

    return W1, b1, W2, b2

# Prediction function
def predict_gate(X, W1, b1, W2, b2):
    a1 = sigmoid(np.dot(X, W1) + b1)
    a2 = sigmoid(np.dot(a1, W2) + b2)
    return np.round(a2), a2

# ---- NAND ----
print("Training for NAND...")
W1_nand, b1_nand, W2_nand, b2_nand = train_gate(X, Y_NAND)
y_pred_nand, y_raw_nand = predict_gate(X, W1_nand, b1_nand, W2_nand, b2_nand)

print("\nPredictions after training for NAND:")
for i in range(len(X)):
    print(f"Input: {X[i]}, Predicted: {int(y_pred_nand[i][0])}, Raw: {y_raw_nand[i][0]:.4f}")

print("\n" + "-"*50 + "\n")

# ---- XOR ----
print("Training for XOR...")
W1_xor, b1_xor, W2_xor, b2_xor = train_gate(X, Y_XOR)
y_pred_xor, y_raw_xor = predict_gate(X, W1_xor, b1_xor, W2_xor, b2_xor)

print("Predictions after training for XOR:")
for i in range(len(X)):
    print(f"Input: {X[i]}, Predicted: {int(y_pred_xor[i][0])}, Raw: {y_raw_xor[i][0]:.4f}")
