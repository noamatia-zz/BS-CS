import torch
import torch.nn as nn


class RNNBase(nn.Module):
    def __init__(self, input_size, hidden_size):
        super(RNNBase, self).__init__()
        self.hidden_size = hidden_size
        self.rnn = nn.RNN(input_size, hidden_size, batch_first=True)

    def forward(self, x):
        h0 = torch.zeros(1, x.size(0), self.hidden_size)
        y, _ = self.rnn(x, h0)
        return y
