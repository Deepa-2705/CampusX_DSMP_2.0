import pandas as pd
import mlflow

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, confusion_matrix

import matplotlib.pyplot as plt
import seaborn as sns

mlflow.set_tracking_uri("https://127.0.0.1:5000")

# Load the Iris dataset
iris = load_iris()
X = iris.data
y = iris.target

# Split the dataset into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(
X, y, test_size=0.2, random_state=42
)

# Train a Decision Tree classifier
max_depth = 15

mlflow.set_experiment("iris-dt")

# Apply mlflow to train
with mlflow.start_run(run_name="dt_confusion_matrix"):

    dt = DecisionTreeClassifier(max_depth=max_depth)
    dt.fit(X_train, y_train)

    # Evaluate the model
    y_pred = dt.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    mlflow.log_param("max_depth", max_depth)
    mlflow.log_metric("accuracy", accuracy)

    # Log confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    plt.figure(figsize=(6, 6))
    sns.heatmap(
    cm,
    annot=True,
    fmt="d",
    cmap="Blues",
    xticklabels=iris.target_names,
    yticklabels=iris.target_names,

    )

    plt.ylabel("Actual")
    plt.xlabel("Predicted")
    plt.title("Confusion Matrix")

    # Save the confusion matrix
    mlflow.log_artifact("confusion_matrix.png")
    mlflow.sklearn.log_model(dt, "decision_tree_model")

    # save the code
    mlflow.log_artifact(__file__)
    mlflow.set_tag("author", "nitish")
    mlflow.set_tag("project", "iris-classification")
    mlflow.set_tag("algorithm", "decision-tree")
    
    print("accuracy:", accuracy)
