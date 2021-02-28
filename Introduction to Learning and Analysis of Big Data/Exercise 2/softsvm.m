#------------------
#Soft-SVM Algorithm
#------------------
# input: A training sample S = {(x1,y1), (x2,y2), ..., (xm,ym)}, a parameter lambda > 0.
# output: A vector w = (w1, w2, ..., wd) that minimizes the objective O.
#   O = (lambda * ||w||^2) + hinge-loss(w, S).
#     hinge-loss(w, S) = (1 / m) * (hinge-loss(w, (x1,y1)) + hinge-loss(w, (x2,y2)) + ... + hinge-loss(w, (xm,ym))).
#       hinge-loss(w, (xi,yi)) = max{0, (1 - yi * <w, xi>)}.
#
#Minimize the objective O is equivalent to minimize O' s.t. (a1) and (a2) and ... and (am) and (b1) and (b2) and ... and (bm).
# O' = (lambda * ||w||^2) + (1 / m) * (E1 + E2 + ... + EM).
# ai = (yi * <w, xi>) >= 1 - Ei.
# bi = Ei >= 0.
#
#
#----------------------------------------------
#Implementing Soft-SVM algorithm using quadprog
#----------------------------------------------
#parameters:
# lambda > 0.
#          |x[1][1] x[1][2] ... x[1][d]| 
#          |x[2][1] x[2][2] ... x[2][d]|          
#          |   .       .           .   |         
# Xtrain = |   .       .           .   | //m examples with d coordinates for each example.  
#          |   .       .           .   |          
#          |x[m][1] x[m][2] ... x[m][d]|
#          
#          |y[1]|
#          |y[2]|
#          |  . |
# Ytrain = |  . | //m labels for each example respectively.
#          |  . |
#          |y[m]|
#
#result:
#            //vector that minimizes f(w[1],w[2],...,w[d],E[1],E[2],...,E[m]) =
#     |w[1]| //                       (lambda * (w[1])^2) + (lambda * (w[2])^2) + ... + (lambda * (w[d])^2) + 
#     |w[2]| //                       ((1 / m) * E[1]) + ((1 / m) * E[2]) + ... + ((1 / m) * E[m]).
#     |  . | //subject to the constraints:  
# w = |  . | //                           -E[1] <= 0, -E[2] <= 0, ..., -E[m] <= 0,
#     |  . | //                           -E[1] - ((x[1][1] * y[1]) * w[1]) - ((x[1][2] * y[1]) * w[2]) - ... - ((x[1][d] * y[1]) * w[d]) <= -1,
#     |w[d]| //                           -E[2] - ((x[2][1] * y[2]) * w[1]) - ((x[2][2] * y[2]) * w[2]) - ... - ((x[2][d] * y[2]) * w[d]) <= -1, ..., 
#            //                           -E[m] - ((x[m][1] * y[m]) * w[1]) - ((x[m][2] * y[m]) * w[2]) - ... - ((x[m][d] * y[m]) * w[d]) <= -1.
#
#In quadprog syntax, this problem is to minimize:
# f(x) = (1/2)*(x^T)*H*x + (f^T)*x.
# x^T = |w[1] w[2] ... w[d] E[1] E[2] ... E[m]|.
#
#where:
#
#     |2*lambda     0    ...     0    0 ... 0|                *      | 0 |                
#     |    0    2*lambda ...     0    0 ... 0|                *      | 0 |             
#     |    .        .            .    .     .|                *      | . |             
#     |    .        .            .    .     .|                *      | . |            
#     |    .        .            .    .     .|                *      | . |             
#     |    0        0    ... 2*lambda 0 ... 0|                *      | 0 |             
# H = |    0        0    ...     0    0 ... 0| //(d+m)X(d+m)  *  f = |1/m| //(d+m)X(1)                 
#     |    0        0    ...     0    0 ... 0|                *      |1/m|           
#     |    .        .            .    .     .|                *      | . |          
#     |    .        .            .    .     .|                *      | . |             
#     |    .        .            .    .     .|                *      | . |             
#     |    0        0    ...     0    0 ... 0|                *      |1/m|          
#
#    |      0             0       ...       0       -1  0 ...  0|               *      | 0|      
#    |      0             0       ...       0        0 -1 ...  0|               *      | 0|   
#    |      .             .                 .        .  .      .|               *      | .|   
#    |      .             .                 .        .  .      .|               *      | .|   
#    |      .             .                 .        .  .      .|               *      | .|   
#    |      0             0       ...       0        0  0 ... -1|               *      | 0|   
# A =|-x[1][1]*y[1] -x[1][2]*y[1] ... -x[1][d]*y[1] -1  0 ...  0| //(2m)X(d+m)  *  b = |-1| //2mX(1)                          
#    |-x[2][1]*y[2] -x[2][2]*y[2] ... -x[2][d]*y[2]  0 -1 ...  0|               *      |-1|  
#    |      .             .                 .        .  .      .|               *      | .|  
#    |      .             .                 .        .  .      .|               *      | .|   
#    |      .             .                 .        .  .      .|               *      | .|   
#    |-x[m][1]*y[m] -x[m][2]*y[m] ... -x[m][d]*y[m]  0  0 ... -1|               *      |-1|


function w = softsvm(lambda, Xtrain, Ytrain)
  [m, d] = size(Xtrain);
  H = build_H(lambda, m, d);  
  f = build_f(m, d);
  A = build_A(Xtrain, Ytrain, m, d);
  b = build_b(m); 
  
  xT = quadprog(H, f, A, b);
  
  w = xT(1:d, :);
endfunction

function H = build_H(lambda, m, d)
  H11 = (2*lambda).*eye(d);
  H12 = zeros(d, m);
  H21 = zeros(m, d);
  H22 = zeros(m, m);
  
  H = [H11 H12; H21 H22]
endfunction

function f = build_f(m, d)
  f1 = zeros(d, 1);
  f2 = (1/m).*ones(m, 1);
  
  f = [f1; f2]
endfunction

function A = build_A(Xtrain, Ytrain, m, d)
  A11 = zeros(m, d);
  A12 = (-1).*eye(m);
  Y = repmat(Ytrain, 1, d);
  A21 = (-1).*(Xtrain.*Y);
  A22 = (-1).*eye(m);
  
  A = [A11 A12; A21 A22]
endfunction

function b = build_b(m)
  b1 = zeros(m, 1);
  b2 = (-1).*ones(m, 1);
  
  b = [b1; b2]
endfunction
