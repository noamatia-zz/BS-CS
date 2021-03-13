import torch.nn as nn
from torch.nn.utils import weight_norm


class ResidualBlock(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size, dropout):
        super(ResidualBlock, self).__init__()
        self.dilation = 1
        self.padding = (kernel_size - 1) * self.dilation
        self.conv1 = weight_norm(nn.Conv1d(in_channels, out_channels, kernel_size,
                                           padding=self.padding, dilation=self.dilation))
        self.relu1 = nn.ReLU()
        self.dropout1 = nn.Dropout(dropout)
        self.conv2 = weight_norm(nn.Conv1d(out_channels, out_channels, kernel_size,
                                           padding=self.padding, dilation=self.dilation))
        self.relu2 = nn.ReLU()
        self.dropout2 = nn.Dropout(dropout)
        self.downsample = None if in_channels == out_channels else nn.Conv1d(in_channels, out_channels, 1)
        self.relu = nn.ReLU()
        self.init_weights()

    def init_weights(self):
        self.conv1.weight.data.normal_(0, 0.01)
        self.conv2.weight.data.normal_(0, 0.01)
        if self.downsample is not None:
            self.downsample.weight.data.normal_(0, 0.01)

    def forward(self, x):
        y = self.conv1(x)[:, :, :-self.padding].contiguous()
        y = self.relu1(y)
        y = self.dropout1(y)
        y = self.conv2(y)[:, :, :-self.padding].contiguous()
        y = self.relu2(y)
        y = self.dropout2(y)
        if self.downsample is None:
            y = self.relu(y + x)
        else:
            y = self.relu(y + self.downsample(x))
        return y
