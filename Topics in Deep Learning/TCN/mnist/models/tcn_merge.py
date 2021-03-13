import torch.nn.functional as F
from torch import nn
from TCN.residual_block_merge import ResidualBlockMerge


class TCNMerge(nn.Module):
    def __init__(self, input_size, hidden_size, output_size, kernel_size, dropout):
        super(TCNMerge, self).__init__()
        self.tcn = ResidualBlockMerge(input_size, hidden_size, kernel_size, dropout)
        self.linear = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        y = self.tcn(x)
        y = self.linear(y[:, :, -1])
        y = F.log_softmax(y, dim=1)
        return y
