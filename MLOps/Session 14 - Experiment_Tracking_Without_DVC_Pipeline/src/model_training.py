import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

from dvclive import Live

df = pd.read_csv('./MLOps/Session 14 - Experiment_Tracking_Without_DVC_Pipeline/data/student_performance.csv')

X = df.iloc[:, :-1]
y = df['Placed']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

n_estimators = 30
max_depth = 1

rf = RandomForestClassifier(n_estimators=n_estimators, max_depth=max_depth)

rf.fit(X_train, y_train)

y_pred = rf.predict(X_test)

accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)

with Live(save_dvc_exp=True) as live:
    live.log_param('n_estimators', n_estimators)
    live.log_param('max_depth', max_depth)

    live.log_metric('accuracy', accuracy)
    live.log_metric('precision', precision)
    live.log_metric('recall', recall)
    live.log_metric('f1_score', f1)