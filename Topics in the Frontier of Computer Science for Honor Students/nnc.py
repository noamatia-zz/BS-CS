from sklearn.neighbors import KNeighborsClassifier
from sklearn.neighbors import DistanceMetric
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from random import randrange
from math import sqrt
import numpy as np

example_size = 13917  # pre-computed - the max page index on the data

metrics = ["euclidean", "manhattan", "chebyshev", "minkowski"]

files = ["Page Cache/10_login_then_select_pass.txt",
         "Page Cache/10_mysql_select_password.txt",
         "Page Cache/10_select_auth_string.txt",
         "Page Cache/10_select_auth_string_then_select_pass.txt",
         "Page Cache/10_select_pass_then_login.txt",
         "Page Cache/10_select_pass_then_select_auth_string.txt",
         "Page Cache/100_login_through_sh.txt"
         ]


class NNC(object):
    def __init__(self, X, Y, metric):
        self.X = X
        self.Y = Y
        self.sampleSize = len(X)
        self.metric = lambda x1, x2: DistanceMetric.get_metric(metric).pairwise([x1, x2])[0][
                                         1] / sqrt(example_size)  # normalized metric
        self.chosenX = None
        self.chosenY = None
        self.chosenIndices = None
        self.compressionRatio = None

    def get_compression_ratio(self):
        """
        Getter for compression ratio
        :return: the compression ratio
        :raise: :class:RuntimeError if :func:NNC.NNC.compress_data was not run before
        """
        if self.compressionRatio is None:
            raise RuntimeError('get_compression_ratio - you must run NNC.compress_data first')
        return self.compressionRatio

    def get_classifier(self):
        """
        Getter for 1-NN classifier fitted on the compressed set
        :return: an :mod:sklearn.KNeighborsClassifier instance
        :raise: :class:RuntimeError if :func:NNC.NNC.compress_data was not run before
        """
        if self.chosenX is None:
            raise RuntimeError('get_classifier - you must run NNC.compress_data first')
        h = KNeighborsClassifier(n_neighbors=1,
                                 metric=self.metric)
        h.fit(self.chosenX, self.chosenY)
        return h

    def compress_data(self, gamma=0.2):
        """
        Run the NNC algorithm to compress the dataset
        :param gamma: scaled margin of the point set
        """
        random_index = randrange(self.sampleSize)
        self.chosenX = [self.X[random_index]]
        self.chosenY = [self.Y[random_index]]
        self.chosenIndices = [random_index]
        for i in range(self.sampleSize):
            if i % int(self.sampleSize / 100) == 0:
                print(f'Compressing Data... {int(i / int(self.sampleSize / 100))}%')
            flag = True
            for x in self.chosenX:
                if self.metric(self.X[i], x) < gamma:
                    flag = False
                    break
            if flag:
                self.chosenX.append(self.X[i])
                self.chosenY.append(self.Y[i])
                self.chosenIndices.append(i)
        self.compressionRatio = self.sampleSize / len(self.chosenX)


def compute_example(line):
    """
    converting line to one dimension binary vector
    where 1 in index i means page index i appears at line
    :param line: string of line of a file of page cache
    :return: a one dimension binary vector with size of example_size
    """
    x = np.zeros(example_size)
    splatted_line = line.strip().split(" ")
    for page in splatted_line:
        if page != '----':
            x[int(page) - 1] = 1
    return x


def data_generator(metric):
    """
    finding gamma for NNC and generating files to train and test data sets
    :param metric: string of metric name
    :return: X_train: vector with size of n_train of binary vectors with size of example_size
             X_test: vector with size of n_test of binary vectors with size of example_size
             Y_train: vector with size of n_train of numbers between 0 to len(files) - 1
             Y_test: vector with size of n_test of numbers between 0 to len(files) - 1
             minimum_gamma: the minimum distance between each 2 examples of different labels
    """
    X, Y, minimum_gamma = [], [], 1
    for i in range(len(files)):
        with open(files[i], "r") as file1:
            print(f'Generating Data... File {i + 1}/{len(files)}')
            for line1 in file1:
                x1 = compute_example(line1)
                X.append(x1)
                Y.append(i)
                for j in range(i + 1, len(files)):
                    with open(files[j], "r") as file2:
                        for line2 in file2:
                            x2 = compute_example(line2)
                            minimum_gamma = min(
                                DistanceMetric.get_metric(metric).pairwise([x1, x2])[0][1] / sqrt(example_size),
                                minimum_gamma)  # normalized metric
    X_train, X_test, Y_train, Y_test = train_test_split(X, Y)
    return X_train, X_test, Y_train, Y_test, minimum_gamma


def main():
    for metric in metrics:
        X_train, X_test, Y_train, Y_test, gamma = data_generator(metric)
        nnc = NNC(X_train, Y_train, metric)
        nnc.compress_data(gamma=gamma)
        print(f'Metric: {metric}')
        print(f'Gamma: {gamma}')
        print(f'Compression Ratio: {nnc.get_compression_ratio()}')
        print(f'NNC Accuracy: {accuracy_score(Y_test, nnc.get_classifier().predict(X_test)) * 100}%')
        nn = KNeighborsClassifier(n_neighbors=1,
                                  metric=lambda x1, x2: DistanceMetric.get_metric(metric).pairwise([x1, x2])[0][
                                                            1] / sqrt(example_size))  # normalized metric
        nn.fit(X_train, Y_train)
        print(f'NN Accuracy: {accuracy_score(Y_test, nn.predict(X_test)) * 100}%')
        print("")


if __name__ == "__main__":
    main()
