import numpy as np
from tabulate import tabulate


def print_tables(L, V):
    np.set_printoptions(linewidth=np.inf)
    print(f'L = {L}')
    headers = ['x1', 'x2', 'x3']
    print(f'V =\n{tabulate(V, headers, tablefmt="fancy_grid")}')


def main():
    A = np.array([[5, -1, 7], [-1, -1, 1], [7, 1, 5]])
    x = np.array([1, 1, 1])
    iter = 9
    L = np.zeros(iter)
    V = np.zeros((iter, 3))

    for i in range(0, iter):
        y = np.matmul(A, x)
        L[i] = max(np.absolute(np.amax(y)), np.absolute(np.amin(y)))
        x = np.divide(y, L[i])
        V[i] = x

    print_tables(L, V)


if __name__ == "__main__":
    main()
