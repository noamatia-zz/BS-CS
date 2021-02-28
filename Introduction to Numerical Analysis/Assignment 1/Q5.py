from math import floor


def adder(man_a, exp_a, man_b, exp_b):
    sum_man = man_a + man_b * (10 ** (exp_b - exp_a))
    sum_exp = exp_a
    while sum_man > 1:  # normalization
        sum_man /= 10
        sum_exp += 1
    sum_man = floor(sum_man * 1000) / 1000  # cutting of 3 digits after the decimal point
    return sum_man, sum_exp


def tar7_ass1(n):
    step_man = 0.1
    step_exp = -2
    res_man = 0.1
    res_exp = -2

    for i in range(2, n):
        res_man, res_exp = adder(res_man, res_exp, step_man, step_exp)

    real_res = 0.001 * n
    approximate_res = res_man * (10 ** res_exp)
    err = abs(real_res - approximate_res)
    return err