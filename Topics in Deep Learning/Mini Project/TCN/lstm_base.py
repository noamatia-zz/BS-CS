import torch
import torch.nn as nn


class LSTMBase(nn.Module):
    def __init__(self, input_size, hidden_size):
        super(LSTMBase, self).__init__()
        self.hidden_size = hidden_size
        self.lstm = nn.LSTM(input_size, hidden_size, batch_first=True)

    def forward(self, x):
        h0 = torch.zeros(1, x.size(0), self.hidden_size)
        c0 = torch.zeros(1, x.size(0), self.hidden_size)
        y, _ = self.lstm(x, (h0, c0))
        return y
