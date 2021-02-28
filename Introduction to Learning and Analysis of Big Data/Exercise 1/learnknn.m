function classifier = learnknn(k, Xtrain, Ytrain)
  
  keySet = {'k','X','Y'};
  valueSet = {k, Xtrain, Ytrain};
  classifier = containers.Map(keySet, valueSet);
  
endfunction