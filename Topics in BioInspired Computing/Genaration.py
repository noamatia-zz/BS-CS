import numpy as np
import random
from Organism import Organism


def mutation(child_weights):
    selection = random.randint(0, len(child_weights) - 1)
    mut = random.uniform(0, 1)
    if mut >= .5:
        child_weights[selection] *= random.randint(2, 5)


def dynamic_crossover(nn1, nn2=None, nn3=None):
    nn1_weights = []
    nn2_weights = []
    nn3_weights = []
    child_weights = []

    for layer in nn1.layers:
        nn1_weights.append(layer.get_weights()[0])

    if nn2 is not None:
        for layer in nn2.layers:
            nn2_weights.append(layer.get_weights()[0])
    if nn3 is not None:
        for layer in nn3.layers:
            nn3_weights.append(layer.get_weights()[0])

    for i in range(0, len(nn1_weights)):
        net_len = np.shape(nn1_weights[i])[1] - 1
        if nn2 is not None:
            split1 = random.randint(0, net_len)
            if nn3:
                split2 = random.randint(split1, net_len)
            else:
                split2 = net_len

            for j in range(split1, split2):
                nn1_weights[i][:, j] = nn2_weights[i][:, j]

            for j in range(split2, net_len):
                nn1_weights[i][:, j] = nn3_weights[i][:, j]

        child_weights.append(nn1_weights[i])

    mutation(child_weights)
    child = Organism(child_weights)
    return child


def crossover(gen_size, prev_gen, num_of_bests, num_of_parents=2):
    cur_gen = []
    for i in range(0, num_of_bests):
        cur_gen.append(prev_gen[i])
    best_firsts = int((gen_size - num_of_bests) / 2)
    for i in range(0, best_firsts):
        for j in range(0, 2):
            if num_of_parents == 1:
                child = dynamic_crossover(prev_gen[i])
            if num_of_parents == 2:
                child = dynamic_crossover(prev_gen[i], random.choice(prev_gen))
            if num_of_parents == 3:
                child = dynamic_crossover(prev_gen[i], random.choice(prev_gen), random.choice(prev_gen))
            cur_gen.append(child)
    return cur_gen
