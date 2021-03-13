import torch
import torch.nn as nn
import torch.optim as optim
import matplotlib.pyplot as plt
from TCN.copy_memory.data_generator import data_generator
from TCN.copy_memory.models.tcn import TCN
from TCN.copy_memory.models.lstm import LSTM
from TCN.copy_memory.models.rnn import RNN

# -----------------------------------------------------------
# example = copy example
# example.shape = 1 X (T + (2 * K))
# -----------------------------------------------------------

# parameters
input_size = 1  # number of rows
hidden_size = 10  # size of the vector that produced by one convolution/block
num_classes = 10  # size of the vector that produced by the networks
batch_size = 32  # number of examples that are learned on one iteration
num_epochs = 10  # number of iterations over the whole train and test dataset
learning_rate = 0.0005  # step size of the optimizer
dropout = 0.0  # tcn parameter
kernel_size = 8  # tcn parameter
K = 10  # the length of the sequence which will need to be remembered
T = 1000  # the length of the blank sequence
num_train = 10000  # number of examples on train dataset
num_test = 1000  # number of examples on test dataset
num_batch = round(num_train / batch_size)

train_x, train_y = data_generator(T, K, num_train)  # train dataset
test_x, test_y = data_generator(T, K, num_test)  # test dataset


# optimizer = optimization algorithm that will hold the current state
#             and will update the parameters based on the computed gradients
# loss_function = measures the performance of a classification model whose output is a probability value between 0 and 1
def optimizer_and_loss_function(model):
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    loss_function = nn.CrossEntropyLoss()
    return optimizer, loss_function


def experiment(model, model_name):
    optimizer, loss_function = optimizer_and_loss_function(model)
    losses = []

    for epoch in range(num_epochs):
        model.train()  # sets the mode to train
        for batch_id in range(num_batch):
            x = train_x[batch_id * batch_size: (batch_id + 1) * batch_size]
            y = train_y[batch_id * batch_size: (batch_id + 1) * batch_size]
            if model_name == 'TCN' or model_name == 'TCNMerge':
                out = model(x.unsqueeze(1).contiguous().float())
            else:
                out = model(x.unsqueeze(2).contiguous())
            loss = loss_function(out.view(-1, num_classes), y.view(-1))  # evaluating the loss
            optimizer.zero_grad()  # set the gradients to zero before the backpropagation
            loss.backward()  # backpropagation
            optimizer.step()  # updates optimizer parameters
            if (batch_id + 1) % 50 == 0:
                print('Model: {}, Epoch: {}/{}, Batch: {}/{}, Loss: {:.5f}'
                      .format(model_name, epoch + 1, num_epochs, batch_id + 1, num_batch, loss.item()))

        model.eval()  # sets the mode to eval
        with torch.no_grad():  # disabling gradient calculation
            if model_name == 'TCN':
                predict = model(test_x.unsqueeze(1).contiguous().float())  # model classification on test dataset
            else:
                predict = model(test_x.unsqueeze(2).contiguous())  # model classification on test dataset
            loss = loss_function(predict.view(-1, num_classes), test_y.view(-1))  # evaluating the loss
            losses.append(loss)
            print('------------------------------------------------------')
            print('Model: {}, Epoch: {}/{}, Loss: {:.5f}'.format(
                model_name, epoch + 1, num_epochs, loss))
            print('------------------------------------------------------')

    return losses


def main():
    epochs = [*range(1, num_epochs+1, 1)]

    tcn = TCN(input_size, hidden_size, num_classes, kernel_size, dropout)
    lstm = LSTM(input_size, hidden_size, num_classes)
    rnn = RNN(input_size, hidden_size, num_classes)

    plt.plot(epochs, experiment(tcn, 'TCN'))
    plt.plot(epochs, experiment(lstm, 'LSTM'))
    plt.plot(epochs, experiment(rnn, 'RNN'))

    plt.xlabel('epoch')
    plt.ylabel('loss')
    plt.legend(['TCN', 'LSTM', 'RNN'])
    plt.show()


if __name__ == "__main__":
    main()
