from scipy.io import loadmat
import torch
import numpy as np


def data_generator(dataset):
    if dataset == "JSB":
        print('loading JSB data...')
        data = loadmat('./mdata/JSB_Chorales.mat')
    elif dataset == "Nott":
        print('loading Nott data...')
        data = loadmat('./mdata/Nottingham.mat')

    X_train = data['traindata'][0]
    X_test = data['testdata'][0]

    for data in [X_train, X_test]:
        for i in range(len(data)):
            data[i] = torch.Tensor(data[i].astype(np.float64))

    return X_train, X_test
