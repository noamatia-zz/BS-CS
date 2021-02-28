import numpy as np
from numpy.linalg import inv
from tabulate import tabulate


def Jacobi(A, b, x, iter):
    [L, D, U] = LDU(A)
    G = np.matmul(np.negative(inv(D)), np.add(L, U))  # -(D^-1)*(L+U)
    C = np.matmul(inv(D), b)  # (D^-1)*b

    Jac = np.zeros((iter, 3))
    Jac[0] = x

    for i in range(1, iter):
        Jac[i] = np.add(np.matmul(G, Jac[i - 1]), C)

    return Jac


def GaussSeidel(A, b, x, iter):
    [L, D, U] = LDU(A)
    G = np.matmul(np.negative(inv(np.add(L, D))), U)  # -((L+D)^-1)*U
    C = np.matmul(inv(np.add(L, D)), b)  # ((L+D)^-1)*b

    GS = np.zeros((iter, 3))
    GS[0] = x

    for i in range(1, iter):
        GS[i] = np.add(np.matmul(G, GS[i - 1]), C)

    return GS


def LDU(A):
    return np.tril(A, -1), np.diag(np.diag(A)), np.triu(A, 1)


def print_tables(Jac, GS):
    headers = ['x1', 'x2', 'x3']
    print(f'Jacobi\n{tabulate(Jac, headers, tablefmt="fancy_grid")}')
    print(f'GaussSeidel\n{tabulate(GS, headers, tablefmt="fancy_grid")}')


def main():
    A = np.array([[4, -1, 1], [4, -8, 1], [-2, 1, 5]])  # A is diagonally dominant
    b = np.array([7, -21, 15])
    x = np.array([1, 2, 2])
    iter = 13
    Jac = Jacobi(A, b, x, iter)
    GS = GaussSeidel(A, b, x, iter)
    print_tables(Jac, GS)


if __name__ == "__main__":
    main()
