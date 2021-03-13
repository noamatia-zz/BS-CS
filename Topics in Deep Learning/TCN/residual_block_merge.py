import math
import torch
import torch.nn as nn
from TCN.residual_block import ResidualBlock


class ResidualBlockMerge(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size, dropout):
        super(ResidualBlockMerge, self).__init__()
        self.res1 = ResidualBlock(math.floor(in_channels/2), math.floor(in_channels/2), kernel_size, dropout)
        self.res2 = ResidualBlock(math.ceil(in_channels/2), math.ceil(in_channels/2), kernel_size, dropout)
        self.res = ResidualBlock(in_channels, out_channels, kernel_size, dropout)

    def forward(self, x):
        x1 = x[:, :math.floor(len(x[0])/2), :]
        x2 = x[:, math.floor(len(x[0])/2):, :]
        y1 = self.res1(x1)
        y2 = self.res2(x2)
        y = torch.cat((y1, y2), dim=1)
        return self.res(y)

