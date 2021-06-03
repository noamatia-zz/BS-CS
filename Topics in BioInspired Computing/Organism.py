import numpy as np
from sklearn.metrics import accuracy_score
from keras.models import Sequential
from keras.layers import Dense


class Organism(Sequential):
    def __init__(self, child_weights=None):
        super().__init__()
        self.fitness = 0
        if child_weights is None:
            layer1 = Dense(4, input_shape=(4,), activation='sigmoid')
            layer2 = Dense(4, activation='sigmoid')
            layer3 = Dense(3, activation='sigmoid')
            self.add(layer1)
            self.add(layer2)
            self.add(layer3)
        else:
            self.add(
                Dense(
                    4,
                    input_shape=(4,),
                    activation='sigmoid',
                    weights=[child_weights[0], np.zeros(4)])
            )
            self.add(
                Dense(
                    4,
                    activation='sigmoid',
                    weights=[child_weights[1], np.zeros(4)])
            )
            self.add(
                Dense(
                    3,
                    activation='sigmoid',
                    weights=[child_weights[2], np.zeros(3)])
            )

    def forward_propagation(self, X_train, Y_train):
        Y_hat = self.predict(X_train)
        Y_hat = Y_hat.argmax(axis=1)
        self.fitness = accuracy_score(Y_train, Y_hat)

    def compile_train(self, epochs, X_train, Y_train,to_print=True):
        yn = np.zeros((len(Y_train), max(Y_train) + 1))
        yn[np.arange(len(Y_train)), Y_train] = 1
        self.compile(
            optimizer='rmsprop',
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        self.fit(X_train, yn, epochs=epochs,verbose=to_print)
