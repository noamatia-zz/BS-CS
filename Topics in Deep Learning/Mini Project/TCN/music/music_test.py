import torch
import numpy as np
import torch.optim as optim
import matplotlib.pyplot as plt
from TCN.music.models.tcn_merge import TCNMerge
from TCN.music.models.tcn import TCN
from TCN.music.models.lstm import LSTM
from TCN.music.models.rnn import RNN
from TCN.music.data_generator import data_generator

# parameters
input_size = 88  # number of keys on a piano
hidden_size = 150  # size of the vector that produced by one convolution/block
num_epochs = 10  # number of iterations over the whole train and test dataset
learning_rate = 0.001  # step size of the optimizer
dropout = 0.25  # tcn parameter
kernel_size = 5  # tcn parameter
data = ['JSB', 'Nott']  # polyphonic music datasets


# loss function in terms of negative log-likelihood: L(y) = -log(y)
def loss_in_terms_of_nll(output, y):
    return -torch.trace(torch.matmul(y, torch.log(output).float().t()) +
                        torch.matmul((1 - y), torch.log(1 - output).float().t()))


# optimizer = optimization algorithm that will hold the current state
#             and will update the parameters based on the computed gradients
# loss_function = measures the performance of a classification model whose output is a probability value between 0 and 1
def optimizer_and_loss_function(model):
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    loss_function = loss_in_terms_of_nll
    return optimizer, loss_function


def experiment(model, model_name, X_train, X_test, dataset):
    optimizer, loss_function = optimizer_and_loss_function(model)
    losses = []

    for epoch in range(num_epochs):
        model.train()  # sets the mode to train
        total_loss = 0
        count = 0
        train_id_list = np.arange(len(X_train), dtype="int32")  # train compositions ids
        np.random.shuffle(train_id_list)  # shuffling the order of the train compositions
        for i, train_id in enumerate(train_id_list):
            data_line = X_train[train_id]  # the train_id's train composition
            x = data_line[:-1]  # first len(data_line) - 1 notes
            y = data_line[1:]  # last len(data_line) - 1 notes
            x = x.unsqueeze(0)  # adding first dimension
            output = model(x)  # model prediction
            output = output.squeeze(0)  # removing first dimension
            loss = loss_function(output, y)  # evaluating the loss
            optimizer.zero_grad()  # set the gradients to zero before the backpropagation
            total_loss += loss.item()  # sum of the loss
            count += output.size(0)  # sum of notes
            loss.backward()  # backpropagation
            optimizer.step()  # updates optimizer parameters
            if (i + 1) % 50 == 0:
                print('Model: {}, Dataset: {}, Epoch: {}/{}, Comp: {}/{}, Loss: {:.5f}'
                      .format(model_name, dataset, epoch + 1, num_epochs, i, len(train_id_list),
                              total_loss / count))
                total_loss = 0.0
                count = 0

        model.eval()  # sets the mode to eval
        test_id_list = np.arange(len(X_test), dtype="int32")  # test compositions ids
        total_loss = 0
        count = 0
        with torch.no_grad():
            for test_id in test_id_list:
                data_line = X_test[test_id]  # the test_id's train composition
                x = data_line[:-1]  # first len(data_line) - 1 notes
                y = data_line[1:]  # last len(data_line) - 1 notes
                x = x.unsqueeze(0)  # adding first dimension
                output = model(x)  # model prediction
                output = output.squeeze(0)  # removing first dimension
                loss = loss_function(output, y)  # evaluating the loss
                total_loss += loss.item()  # sum of the loss
                count += output.size(0)  # sum of notes
            loss = total_loss / count
            losses.append(loss)
            print('---------------------------------------------------------------------')
            print('Model: {}, Dataset: {}, Epoch: {}/{}, Loss: {:.5f}'.format(
                model_name, dataset, epoch + 1, num_epochs, loss))
            print('---------------------------------------------------------------------')

    return losses


def main():
    epochs = [*range(1, num_epochs + 1, 1)]

    for dataset in data:
        X_train, X_test = data_generator(dataset)
        tcn_merge = TCNMerge(input_size, hidden_size, input_size, kernel_size, dropout)
        tcn = TCN(input_size, hidden_size, input_size, kernel_size, dropout)
        lstm = LSTM(input_size, hidden_size, input_size)
        rnn = RNN(input_size, hidden_size, input_size)

        plt.plot(epochs, experiment(tcn_merge, 'TCNMerge', X_train, X_test, dataset))
        plt.plot(epochs, experiment(tcn, 'TCN', X_train, X_test, dataset))
        plt.plot(epochs, experiment(lstm, 'LSTM', X_train, X_test, dataset))
        plt.plot(epochs, experiment(rnn, 'RNN', X_train, X_test, dataset))

        plt.xlabel('epoch')
        plt.ylabel('loss')
        plt.legend(['TCNMerge', 'TCN', 'LSTM', 'RNN'])
        plt.show()


if __name__ == "__main__":
    main()
