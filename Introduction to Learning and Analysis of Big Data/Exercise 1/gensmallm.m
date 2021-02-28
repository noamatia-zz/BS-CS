function [X,Y] = gensmallm(labelAsample, labelBsample, labelCsample, labelDsample, A, B, C, D, samplesize)
%load('mnist_all.mat') then use this function on two digits
alldata = double([labelAsample;labelBsample;labelCsample;labelDsample]);
alllabels = [A* ones(size(labelAsample,1),1);B* ones(size(labelBsample,1),1);C* ones(size(labelCsample,1),1);D* ones(size(labelDsample,1),1)];
[m,d] = size(alldata);
perm = randperm(m);
trainind = perm(1:samplesize);
X = alldata(trainind,:);
Y = alllabels(trainind);

