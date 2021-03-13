from torch import nn
from TCN.rnn_base import RNNBase


class RNN(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(RNN, self).__init__()
        self.rnn = RNNBase(input_size, hidden_size)
        self.linear = nn.Linear(hidden_size, output_size)
        self.sig = nn.Sigmoid()

    def forward(self, x):
        y = self.rnn(x)
        y = self.linear(y)
        y = self.sig(y)
        return y
