from sklearn.metrics import accuracy_score
from Genaration import crossover
from DataGenerator import DataGenerator
from Organism import Organism
import time

# params
dataset_name = 'iris.csv'
class_col = 'variety'
gen_sizes = [10, 20, 30]  # must be even
nums_of_gens = [0, 10, 20, 30]
nums_of_parents = [1, 2, 3]  # only 1-3 is supported
nums_of_bests = [0, 2, 4]  # must be even
epochs_list = [1, 10, 20, 30]
to_print = True
repeat = 100

X_train, Y_train, X_test, Y_test = DataGenerator(dataset_name, class_col)


def evolution(gen_size, num_of_gens, num_of_parents, num_of_bests, epochs, to_print):
    start_time = time.time()
    cur_gen = []
    prev_gen = []
    n_gen = 0
    best_org_fit = 0
    best_org_weights = []

    # initializing generation 0
    for i in range(0, gen_size):
        cur_gen.append(Organism().forward_propagation(X_train, Y_train))
    cur_gen = sorted(cur_gen, key=lambda x: x.fitness)
    cur_gen.reverse()
    best_org_fit = cur_gen[0].fitness
    for layer in cur_gen[0].layers:
        best_org_weights.append(layer.get_weights()[0])

    # start evolution
    while n_gen < num_of_gens:
        n_gen += 1
        prev_gen.clear()
        # compute fitness for each organism on current generation
        for org in cur_gen:
            org.forward_propagation(X_train, Y_train)
            prev_gen.append(org)

        cur_gen.clear()
        prev_gen = sorted(prev_gen, key=lambda x: x.fitness)
        prev_gen.reverse()
        # save the fitness of the best organism of current generation
        cur_best_fit = prev_gen[0].fitness

        # save the fitness and weights of the best organism until now
        if cur_best_fit > best_org_fit:
            best_org_fit = cur_best_fit
            best_org_weights.clear()
            for layer in prev_gen[0].layers:
                best_org_weights.append(layer.get_weights()[0])
        if to_print:
            print('Generation: %1.f' % n_gen, '\tBest Fitness: %.4f' % cur_best_fit)
        # crossover current generation
        cur_gen = crossover(gen_size, prev_gen, num_of_bests, num_of_parents)

    best_organism = Organism(best_org_weights)
    best_organism.compile_train(epochs, X_train, Y_train, to_print)

    # test
    Y_hat = best_organism.predict(X_test)
    Y_hat = Y_hat.argmax(axis=1)
    end_time = time.time()
    return accuracy_score(Y_test, Y_hat), end_time - start_time


def main():
    for gen_size in gen_sizes:
        for num_of_gens in nums_of_gens:
            for num_of_parents in nums_of_parents:
                for num_of_bests in nums_of_bests:
                    for epochs in epochs_list:
                        print('*************************')
                        print(f'Generation Size: {gen_size}')
                        print(f'Number Of Generations: {num_of_gens}')
                        print(f'Number Of Parents: {num_of_parents}')
                        print(f'Number Of Bests: {num_of_bests}')
                        print(f'Epoch: {epochs}')
                        print('*************************')
                        for i in range(repeat):
                            test_acc, total_time = evolution(gen_size, num_of_gens, num_of_parents, num_of_bests,
                                                             epochs,
                                                             to_print)
                            print('*************************')
                            print('Test Accuracy: %.2f' % test_acc)
                            print('Total Time (seconds): %.2f' % total_time)
                            print('*************************')


if __name__ == '__main__':
    main()
