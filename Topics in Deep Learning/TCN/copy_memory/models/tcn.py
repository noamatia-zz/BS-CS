from torch import nn
from TCN.residual_block import ResidualBlock


class TCN(nn.Module):
    def __init__(self, input_size, hidden_size, output_size, kernel_size, dropout):
        super(TCN, self).__init__()
        self.tcn = ResidualBlock(input_size, hidden_size, kernel_size, dropout)
        self.linear = nn.Linear(hidden_size, output_size)
        self.init_weights()

    def init_weights(self):
        self.linear.weight.data.normal_(0, 0.01)

    def forward(self, x):
        y1 = self.tcn(x)
        return self.linear(y1.transpose(1, 2))