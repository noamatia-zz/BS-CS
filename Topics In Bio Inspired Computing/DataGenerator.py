from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import pandas as pd


def DataGenerator(dataset_name, class_col):
    df = pd.read_csv(dataset_name)

    # the classes for classification
    classes = sorted(list(set(df[class_col])))

    # mapping class name to unique number
    class_number = {y: x for x, y in enumerate(classes)}

    # extracting and splitting data
    X = df.drop([class_col], axis=1)
    Y = [class_number[x] for x in df[class_col]]
    X_train, X_test, Y_train, Y_test = train_test_split(X, Y)

    # normalizing data
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)

    return X_train, Y_train, X_test, Y_test
