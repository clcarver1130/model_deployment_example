# CODE TO RUN LOCALLY ONCE TO CREATE model.pkl
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import load_iris
import pickle
import os

# Load a simple dataset
X, y = load_iris(return_X_y=True)

# Train a simple model
model = LogisticRegression(max_iter=200)
model.fit(X, y)

# Save the model
model_path = os.path.join('inference', 'model.pkl')
os.makedirs('inference', exist_ok=True) # Ensure the directory exists

with open(model_path, 'wb') as f:
    pickle.dump(model, f)

print(f"Model saved to {model_path}")