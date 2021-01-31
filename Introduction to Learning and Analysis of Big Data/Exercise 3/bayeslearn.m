#----------------------
#Bayes-Optimal Decision
#----------------------
#X = {-1,1}^d                  //d experts who give binay advice
#Y = {-1, 1}                   //the correct advice
#joint distribution D over XxY
#
#Bayes-optimal decision:
# h(x) = argmax y in Y{P[Y=y|X=x]}
#
#problem:
# evaluating h requires knowing 2^d parameters, 
# one for each x in X                           //need to see all possible x's in the sample
#
#----------------------
#Naive-Bayes Assumption
#----------------------
#P[X=x|Y=y] = P[X(1)=x(1)|Y=y] * P[X(2)=x(2)|Y=y] * ... * P[X(d)=x(d)|Y=y] = pai(P[X=x|Y=y]) //experts are conditionally independent
#
#h(x) = argmax y in Y{P[Y=y|X=x]} =       //Bayes' law
# = argmax y in Y{P[Y=y & X=x]/P[X=x]} =  //can be multiplied by P[X=x]
# = argmax y in Y{P[Y=y & X=x]} =         //Bayes' law
# = argmax y in Y{P[Y=y]*P[X=x|Y=y]} =    //Naive-Bayes assumption
# = argmax y in Y{P[Y=y]*pai(P[X=x|Y=y])}
#
#solution:
# under the Naive-Bayes assumption, evaluating h requires knowing 2d+1 parameters //instead of 2^d
#
#----------
#bayeslearn
#----------
#parameters:
#          |x[1][1] x[1][2] ... x[1][d]| 
#          |x[2][1] x[2][2] ... x[2][d]|          
#          |   .       .           .   | //m examples with d coordinates (experts) for each example.       
# Xtrain = |   .       .           .   | //all entries in the matrix are binary, in {0, 1}.   
#          |   .       .           .   |          
#          |x[m][1] x[m][2] ... x[m][d]|
#          
#          |y[1]|
#          |y[2]|
#          |  . | //m labels for each example respectively.
# Ytrain = |  . | //all entries in the vector are in {-1, 1}.  
#          |  . |
#          |y[m]|
#
#result:
# allpos //P[Y=1]
#
#                                      //          NaN                                    , P[Y=1] = 0
# ppos = |ppos[1] ppos[2] ... ppos[d]| //ppos[i] =
#                                      //          P[X[i]=1|Y=1] = P[X[i]=1 & Y=1]/P[Y=1] , otherwise
#
#                                      //          NaN                                       , P[Y=-1] = 0
# pneg = |pneg[1] pneg[2] ... pneg[d]| //pneg[i] =
#                                      //          P[X[i]=1|Y=-1] = P[X[i]=1 & Y=-1]/P[Y=-1] , otherwise


function [allpos, ppos, pneg] = bayeslearn(Xtrain, Ytrain)
  [m, d] = size(Xtrain);
  sumOfLabels = sum(Ytrain);
  
  if sumOfLabels == m
    [allpos, ppos, pneg] = onlyPosLabels(Xtrain, m, d);
  elseif sumOfLabels == (-1)*m
    [allpos, ppos, pneg] = onlyNegLabels(Xtrain, m, d);
  else
    numOfPosLabels = (sumOfLabels + m)/2;
    [allpos, ppos, pneg] = mixLabels(Xtrain, Ytrain, m, d, numOfPosLabels);
  endif
endfunction

function [allpos, ppos, pneg] = onlyPosLabels(Xtrain, m, d)
  allpos = 1;
  ppos = zeros(1, d);
  pneg = NaN(1, d);
  sumOfExamples = sum(Xtrain);   
  
  for i = 1:d
    ppos(i) = sumOfExamples(i)/m;
  endfor 
endfunction

function [allpos, ppos, pneg] = onlyNegLabels(Xtrain, m, d)
  allpos = 0;
  ppos = NaN(1, d);
  pneg = zeros(1, d);
  sumOfExamples = sum(Xtrain);   
  
  for i = 1:d
    pneg(i) = sumOfExamples(i)/m; 
  endfor
endfunction

function [allpos, ppos, pneg] = mixLabels(Xtrain, Ytrain, m, d, numOfPosLabels)
  allpos = numOfPosLabels/m;
  ppos = zeros(1, d);
  pneg = zeros(1, d);
  
  yPlusOne = (Ytrain + 1).';
  yMinusOne = (Ytrain - 1).';
  
  for i = 1:d
    xi = Xtrain(:, i);
    xOneAndYOne = (yPlusOne*xi)/2;
    xOneAndYMinusOne = ((-1)*(yMinusOne*xi))/2;
    ppos(i) = (xOneAndYOne/m)/allpos;
    pneg(i) = (xOneAndYMinusOne/m)/(1-allpos);
  endfor 
endfunction
