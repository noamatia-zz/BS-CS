import torch
import torch.nn as nn
import torch.optim as optim
import matplotlib.pyplot as plt
from TCN.mnist.data_generator import data_generator
from TCN.mnist.models.tcn_merge import TCNMerge
from TCN.mnist.models.tcn import TCN
from TCN.mnist.models.lstm import LSTM
from TCN.mnist.models.rnn import RNN

# -----------------------------------------------------------
# image = MNIST image
# image.shape = 28 X 28
# image as sequence = [c(1), c(2), ... , c(sequence_length)]
# ci = image column, vector of size input_size
# -----------------------------------------------------------

# parameters
sequence_length = 28  # number of columns
input_size = 28  # number of rows
hidden_size = 128  # size of the vector that produced by one convolution/block
num_classes = 10  # size of the vector that produced by the networks
batch_size = 64  # number of images that are learned on one iteration
num_epochs = 10  # number of iterations over the whole train and test dataset
learning_rate = 0.002  # step size of the optimizer
dropout = 0.05  # tcn parameter
kernel_size = 7  # tcn parameter
num_test = 10000  # number of examples on test dataset

train_loader, test_loader = data_generator('./data/mnist', batch_size)  # loading the train and test dataset
num_train = len(train_loader)  # number of images on train dataset


# reshape from [batch_size X 1 X input_size X sequence_length]
# to [batch_size X input_size X sequence_length]
def reshape(images):
    return images.reshape(-1, input_size, sequence_length)


# optimizer = optimization algorithm that will hold the current state
#             and will update the parameters based on the computed gradients
# loss_function = measures the performance of a classification model whose output is a probability value between 0 and 1
def optimizer_and_loss_function(model):
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    loss_function = nn.CrossEntropyLoss()
    return optimizer, loss_function


def experiment(model, model_name):
    optimizer, loss_function = optimizer_and_loss_function(model)
    accuracies = []

    for epoch in range(num_epochs):
        model.train()  # sets the mode to train
        for batch_id, (images, labels) in enumerate(train_loader):
            images = reshape(images)  # reshaping images
            predict = model(images)  # model classification on batch_size images from train dataset
            loss = loss_function(predict, labels)  # evaluating the loss
            optimizer.zero_grad()  # set the gradients to zero before the backpropagation
            loss.backward()  # backpropagation
            optimizer.step()  # updates optimizer parameters
            if (batch_id + 1) % 50 == 0:
                print('Model: {}, Epoch: {}/{}, Batch: {}/{}, Loss: {:.5f}'
                      .format(model_name, epoch + 1, num_epochs, batch_id + 1, num_train, loss.item()))

        model.eval()  # sets the mode to eval
        with torch.no_grad():  # disabling gradient calculation
            correct = 0
            for images, labels in test_loader:
                images = reshape(images)  # reshaping images
                predict = model(images)  # model classification on batch_size images from test dataset
                _, predictions = torch.max(predict.data, 1)  # batch_size distribution vectors to unit vectors
                correct += (predictions == labels).sum().item()  # sum of correct predictions
        accuracy = 100 * correct / num_test
        accuracies.append(accuracy)
        print('------------------------------------------------------')
        print('Model: {}, Epoch: {}/{}, Correct Predictions: {}/{}, Accuracy: {} %'.format(
              model_name, epoch + 1, num_epochs, correct, num_test, accuracy))
        print('------------------------------------------------------')

    return accuracies


def main():
    epochs = [*range(1, num_epochs + 1, 1)]

    tcn_merge = TCNMerge(input_size, hidden_size, num_classes, kernel_size, dropout)
    tcn = TCN(input_size, hidden_size, num_classes, kernel_size, dropout)
    lstm = LSTM(input_size, hidden_size, num_classes)
    rnn = RNN(input_size, hidden_size, num_classes)

    plt.plot(epochs, experiment(tcn_merge, 'TCNMerge'))
    plt.plot(epochs, experiment(tcn, 'TCN'))
    plt.plot(epochs, experiment(lstm, 'LSTM'))
    plt.plot(epochs, experiment(rnn, 'RNN'))

    plt.xlabel('epoch')
    plt.ylabel('accuracy')
    plt.legend(['TCNMerge', 'TCN', 'LSTM', 'RNN'])
    plt.show()


if __name__ == "__main__":
    main()
