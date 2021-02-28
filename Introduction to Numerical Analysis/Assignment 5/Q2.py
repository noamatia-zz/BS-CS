import numpy as np
import scipy.integrate as integrate

C1 = 2
C5 = -1
X = [-1 ,1, 1.5, 2, 2.5, 3]

def N(i, x): 
  if (X[i-1] <= x and x <= X[i]):
    return (x - X[i-1])/0.5
  elif (X[i] <= x and x <= X[i+1]):
    return (X[i+1] - x)/0.5
  else:
    return 0

def dN(i, x): 
  if (X[i-1] <= x and x <= X[i]):
    return 2
  elif (X[i] <= x and x <= X[i+1]):
    return -2
  else:
    return 0

def main():
  A = np.zeros((3, 5))
  b = np.zeros(3)
  
  for j in range(2, 5):
    b[j-2] = (-1)*integrate.quad(lambda x: x*N(j, x), 1, 3)[0]
    for i in range (1, 6):
      A[j-2][i-1] = integrate.quad(lambda x: dN(j, x)*dN(i, x) + (1-x/5)*N(j, x)*N(i, x), 1, 3)[0]

  for k in range(3):
    b[k] = b[k] - C1*A[k][0] - C5*A[k][4]
  A = A[:, 1:4]
  
  C = np.linalg.solve(A, b)

  print(f'C1 = {C1}')
  print(f'C2 = {C[0]}')
  print(f'C3 = {C[1]}')
  print(f'C4 = {C[2]}')
  print(f'C5 = {C5}')


if __name__ == "__main__":
  main()