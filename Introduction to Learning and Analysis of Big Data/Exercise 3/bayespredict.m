#under Naive-Bayes Assumption, the classification rule is:
#h(x) = argmax y in Y{P[Y=y] * P[X(1)=x(1)|Y=y] * P[X(2)=x(2)|Y=y] * ... * P[X(d)=x(d)|Y=y]}
#
#                                    h(x) = 1  
#
#                                      <=>
#
# P[Y=1] * P[X(1)=x(1)|Y=1] * P[X(2)=x(2)|Y=1] * ... * P[X(d)=x(d)|Y=1] >=
#   >= P[Y=-1] * P[X(1)=x(1)|Y=-1] * P[X(2)=x(2)|Y=-1] * ... * P[X(d)=x(d)|Y=-1]
#
#                                      <=>
#
# log(P[Y=1] * P[X(1)=x(1)|Y=1] * P[X(2)=x(2)|Y=1] * ... * P[X(d)=x(d)|Y=1]) >= 
#   >= log(P[Y=-1] * P[X(1)=x(1)|Y=-1] * P[X(2)=x(2)|Y=-1] * ... * P[X(d)=x(d)|Y=-1])
#
#                                      <=>
#
# log(P[Y=1]) + log(P[X(1)=x(1)|Y=1]) + log(P[X(2)=x(2)|Y=1]) + ... + log(P[X(d)=x(d)|Y=1])) >=
#   >= log(P[Y=-1]) + log(P[X(1)=x(1)|Y=-1]) + log(P[X(2)=x(2)|Y=-1]) + ... + log(P[X(d)=x(d)|Y=-1]))
#
#------------
#bayespredict
#------------
#parameters:
# allpos //P[Y=1]
#
#                                      //          NaN            , P[Y=1] = 0
# ppos = |ppos[1] ppos[2] ... ppos[d]| //ppos[i] =
#                                      //          P[X[i]=1|Y=1]  , otherwise
#
#                                      //          NaN            , P[Y=-1] = 0
# pneg = |pneg[1] pneg[2] ... pneg[d]| //pneg[i] =
#                                      //          P[X[i]=1|Y=-1] , otherwise
# 
#         |x[1][1] x[1][2] ... x[1][d]| 
#         |x[2][1] x[2][2] ... x[2][d]|          
#         |   .       .           .   | //m test examples with d coordinates for each example.       
# Xtest = |   .       .           .   | //all entries in the matrix are binary, in {0, 1}.   
#         |   .       .           .   |          
#         |x[m][1] x[m][2] ... x[m][d]|
#
#result:
#            |y[1]|
#            |y[2]|
#            |  . | 
# Ypredict = |  . | //y[i] = h(|x[i][1] x[i][2] ... x[i][d]|)  
#            |  . |
#            |y[m]|
  

function Ypredict = bayespredict(allpos, ppos, pneg, Xtest)
  
  if allpos == 0 || allpos == 1
    Ypredict = 0;
    return;
  endif
  
  [m, d] = size(Xtest);
  Ypredict = zeros(m, 1);
    
  for i = 1:m
    left = log(allpos);
    right = log(1-allpos);
    for j = 1:d   
      if Xtest(i,j) == 1
        left = left + log(ppos(j));
        right = right + log(pneg(j));
      else
        left = left + log(1 - ppos(j));
        right = right + log(1 - pneg(j));
      endif
    endfor      
    if left >= right
      Ypredict(i) = 1;
    else
      Ypredict(i) = -1;
    endif
  endfor
endfunction
