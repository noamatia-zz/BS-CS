function Ytestprediction = predictknn(classifier, Xtest)
  
  k = classifier('k');
  Xtrain = classifier('X');
  Ytrain = classifier('Y');
  sizeOfSample = length(Ytrain);
  numOfExamples = length(Xtest);
  Ytestprediction = zeros(numOfExamples, 1);
  
  for i = 1:numOfExamples
    
    distLabel = zeros(sizeOfSample, 2);
    
    for j = 1:sizeOfSample
      
      v1 = Xtest(i, :);
      v2 = Xtrain(j, :);
      dist = norm(v1 - v2);
      label = Ytrain(j);
      distLabel(j, :) = [dist label];
      
    endfor
    
    distLabelSorted = sortrows(distLabel) ;   
    kLabels = distLabelSorted(1:k ,2);
    maj = mode(kLabels)    ;
    Ytestprediction(i) = maj;
    
  endfor
  
endfunction

%!test
%!  k1 = 1
%!  Xtrain1 = [1, 2; 3, 4; 5, 6]
%!  Ytrain1 = [1; 0; 1]
%!  classifier1 = learnknn(k1, Xtrain1, Ytrain1)
%!  Xtest1 = [10, 11; 3.1, 4.2; 2.9, 4.2; 5, 6]
%!  assert(predictknn(classifier1, Xtest1), [1; 0; 0; 1])

%!test
%!  k2 = 3
%!  Xtrain2 = [6, 5; 4.5, -3; 4, 5; 4, -2; 7, -4; 3.1, -3.2; 6, 7; 4, 7; 5, 3; 3.4, 3]3
%!  Ytrain2 = [2; 0; 4; 1; 1; 1; 3; 2; 2; 4]
%!  classifier2 = learnknn(k2, Xtrain2, Ytrain2)
%!  Xtest2 = [4.5, -3; 5, 6; 5, 4; 3, 4]
%!  assert(predictknn(classifier2, Xtest2), [1; 2; 2; 4])