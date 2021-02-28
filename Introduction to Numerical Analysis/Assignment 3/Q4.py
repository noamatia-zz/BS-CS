import numpy as np
import matplotlib.pyplot as plt

x = np.array([0.25, 0.5, 1, 2, 3, 4, 5])
y = np.array([0.9, 1.2, 0.5, 0.15, 0.033, 0.005, 0.001])

X = x
Y = np.log(y/x)
Z = np.polyfit(X, Y, 1)

b = -Z[0]
a = np.exp(Z[1])

f = (a)*(x)*(np.exp(-b*x))

print("a : {} b : {}".format(a, b))
plt.plot(x, y, 'r--', x, f, 'b--')
plt.show()