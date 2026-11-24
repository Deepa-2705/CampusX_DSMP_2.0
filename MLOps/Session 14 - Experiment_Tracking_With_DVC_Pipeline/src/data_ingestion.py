import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
import os

#url to download datset
url = 'https://raw.githubusercontent.com/campusx-official/toy-datasets/main/student_performance.csv'

#read the dataset
df = pd.read_csv(url)

#split the dataset
train, test = train_test_split(df, test_size=0.2, random_state=42)

train.to_csv("./data/raw/train.csv", index=False)
test.to_csv("./data/raw/test.csv", index=False)