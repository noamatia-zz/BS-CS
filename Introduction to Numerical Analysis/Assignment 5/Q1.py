import numpy as np
from tabulate import tabulate

h = 0.1
lam = 2/3
x = np.linspace(0, 1, length)
f = lambda x, y : x + y
a1 = 1 - (1/(2*lam))
k1 = f
a2 = 1/(2*lam)
k2 = lambda x, y : f(x + (lam*h), y + (lam*h*k1(x, y)))

length = 11 # (1/h)+1

def em():
  Y = np.zeros(length)
  Y[0] = 1
  for i in range(1, length):
    Y[i] = Y[i-1] + h*f(Y[i-1], x[i-1])
  return Y

def rk2():
  Y = np.zeros(length)
  Y[0] = 1
  for i in range(1, length):
    Y[i] = Y[i-1] + h*(a1*k1(x[i-1], Y[i-1]) + a2*k2(x[i-1], Y[i-1]))
  return Y

def es():
  Y = np.zeros(length)
  for i in range(0, length):
    Y[i] = 2*np.exp(x[i]) - x[i] - 1
  return Y

def main():
  headers = ['x', 'EM', 'RK2', 'EXACT SOLUTION']
  V = np.c_[x, em(), rk2(), es()]
  print(f'{tabulate(V, headers, tablefmt="fancy_grid")}')

if __name__ == "__main__":
  main()