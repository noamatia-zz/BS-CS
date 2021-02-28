  %lambda - the parameter ? of the soft SVM algorithm.
  %
  %sigma - the bandwidth parameter ? of the RBF kernel.
  %
  %                    |x11 x12 ... x1d|          |y1|                |a1|     |E1|
  %                    |x21 x22 ... x2d|          |y2|                |a2|     |E2|
  %                    | .   .       . |          | .|                | .|     | .|
  %lambda = ?,Xtrain = | .   .       . |,Ytrain = | .|,sigma = s, a = | .|,E = | .|
  %                    | .   .       . |          | .|                | .|     | .|
  %                    |xm1 xm2 ... xmd|          |ym|                |am|     |Em|
  %
  %subject to the constraints:                             |   0      0   ...    0   -1  0 ...  0|     | 0|
  % -E1<=0, -E2<=0, ..., -Em<=0,                           |   0      0   ...    0    0 -1 ...  0|     | 0|
  % -E1-(y1G[1]1)a1-(y1G[1]2)a2-...-(y1G[1]m)am<=-1,==>    |   .      .          .    .  .      .|     | .|
  % -E2-(y2G[2]1)a2-(y2G[2]2)a2-...-(y2G[2]m)am<=-1,       |   .      .          .    .  .      .|     | .|
  % -E3-(y3G[3]1)a3-(y3G[3]2)a2-...-(y3G[3]m)am<=-1,       |   .      .          .    .  .      .|     | .|
  %                                                        |   0      0   ...    0    0  0 ... -1|     | 0|
  %                                                     A =|-y1G[1]1 ...   -y1G[1]m  -1 ...     0| b = |-1|
  %                                                        |   .      .    ...   .    . ...     .|     |-1|
  %                                                        |   .      .          .    .  .      .|     | .|
  %                                                        |   .      .          .    .  .      .|     | .|
  %                                                        |   .      .          .    .  .      .|     | .|
  %                                                        |-ymG[m]1 ...  -ymG[m]m    0 ...    -1|     |-1|
  %In quadprog syntax, this problem is to minimize:
  % f(z) = (1/2)*(z^T)*H*z + (f^T)*z
  %
  %where:
  %     |2?  0 ...  0 0 ... 0|     | 0 |      |a1|                         
  %     | 0 2? ...  0 0 ... 0|     | 0 |      |a2|                         
  %     | .  .      . .     .|     | . |      | .|                         
  %     | .  .      . .     .|     | . |      | .|                         
  %     | .  .      . .     .|     | . |      | .|                        
  %     | 0  0 ... 2? 0 ... 0|     | 0 |      |am|                         
  % H = | 0  0 ...  0 0 ... 0|,u = |1/m|, z = |E1|                             
  %     | 0  0 ...  0 0 ... 0|     |1/m|      |E2|                         
  %     | .  .      . .     .|     | . |      | .|                        
  %     | .  .      . .     .|     | . |      | .|                        
  %     | .  .      . .     .|     | . |      | .|                         
  %     | 0  0 ...  0 0 ... 0|     |1/m|      |Em|
  %
  %
  %
  %
  %
  
function alpha = softsvmrbf(lambda, sigma, Xtrain, Ytrain)
  
  %calculate G
  [m, d] = size(Xtrain);
  G = zeros(m, m);
  
  for i = 1:m
    for j = 1:m
      temp = -1*norm(Xtrain(i,:)-Xtrain(j,:))^2;
      G(i,j) = exp(temp/(2*sigma));
    end
  end
  
  %calculate H
  H11 = (2*lambda).*eye(m);
  H12 = zeros(m, m);
  H21 = zeros(m, m);
  H22 = zeros(m, m);
  H = [H11 H12; H21 H22];
  
  %calculate f  
  f1 = zeros(m, 1);
  f2 = (1/m).*ones(m, 1);
  f = [f1; f2];
  
  %calculate b
   b1 = zeros(m, 1);
   b2 = (-1).*ones(m, 1);
   b = [b1; b2];
   
  %calculate A
  A11 = zeros(m, m);
  A12 = (-1).*eye(m);
  Y = repmat(Ytrain, 1, m);
  A21 = (-1).*(G.*Y);
  A22 = (-1).*eye(m);
  A = [A11 A12; A21 A22];
  
  alpha_E = quadprog(H, f, A, b);
  alpha = alpha_E(1:m, :);
end
