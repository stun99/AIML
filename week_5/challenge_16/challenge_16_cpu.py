import torch
import torch.nn as nn
import time

# Define model
model = nn.Sequential(
    nn.Linear(5, 5), nn.Tanh(),
    nn.Linear(5, 1)
)

# Use CPU
device = torch.device('cpu')
model.to(device)

# Loss and optimizer
loss_fn = nn.MSELoss()
optimizer = torch.optim.SGD(model.parameters(), lr=0.01)

# Dummy data
X = torch.randn(10000, 5, device=device)
Y = torch.randn(10000, 1, device=device)

# Timing (no need for cuda.synchronize on CPU)
start_time = time.perf_counter()

# Training loop
for epoch in range(10000):
    optimizer.zero_grad()
    Yp = model(X)
    loss = loss_fn(Yp, Y)
    loss.backward()
    optimizer.step()

end_time = time.perf_counter()

print(f"Training completed in {end_time - start_time:.4f} seconds on CPU")
