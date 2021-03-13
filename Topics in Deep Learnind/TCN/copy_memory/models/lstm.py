from torch import nn
from TCN.lstm_base import LSTMBase


class LSTM(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(LSTM, self).__init__()
        self.lstm = LSTMBase(input_size, hidden_size)
        self.linear = nn.Linear(hidden_size, output_size)
        self.init_weights()

    def init_weights(self):
        self.linear.weight.data.normal_(0, 0.01)

    def forward(self, x):
        y = self.lstm(x)
        y = self.linear(y)
        return y
