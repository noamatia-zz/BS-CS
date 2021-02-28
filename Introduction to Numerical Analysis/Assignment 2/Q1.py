import math


def bisection_method(f, a, b, delta):
    """
    :param f: The function for which we are looking for a root
    :param a, b: [a, b] is a bracket of f, i.e. f(a) * f(b) < 0
    :param delta: tolerance value s.t delta > 0
    :return:    z - the approximation of the root that we found,
                iteration_number - the number of iteration takes to find z
    """
    iteration_number = 0
    while True:
        iteration_number += 1
        z = (a + b) / 2
        print(f"iteration number: {iteration_number}, z: {z}")
        if f(a) * f(z) < 0:
            b = z
        else:
            a = z
        if abs(b - a) < 2 * delta:
            break
    z = (a + b) / 2
    return z, iteration_number


def regula_falsi_method(f, x_i, x_ii, delta):
    """
    :param f: The function for which we are looking for a root
    :param x_i, x_ii: initial guesses and [x_i, x_ii] is a bracket of f, i.e. f(x_i) * f(x_ii) < 0
    :param delta: tolerance value s.t delta > 0
    :return:    z - the approximation of the root that we found,
                iteration_number - the number of iteration takes to find z
    """
    iteration_number = 0
    while True:
        iteration_number += 1
        z = x_ii - f(x_ii) * ((x_ii - x_i) / (f(x_ii) - f(x_i)))
        print(f"iteration number: {iteration_number}, z: {z}")
        if f(z) * f(x_ii) < 0:
            x_i = z
        else:
            x_ii = z
        if abs(f(z)) < delta:
            break
    z = x_ii - f(x_ii) * ((x_ii - x_i) / (f(x_ii) - f(x_i)))
    return z, iteration_number


if __name__ == '__main__':
    f = lambda x: (x ** 3 - 1) - math.cos(x)
    print("-bisection method-")
    z, iteration_number = bisection_method(f, -3, 3, 0.001)
    print(f"total iterations number: {iteration_number}, final root: {z}")
    print("-regula falsi method-")
    z, iteration_number = regula_falsi_method(f, -3, 3, 0.001)
    print(f"total iterations number: {iteration_number}, final root: {z}")
