import gym
from MonteCarloTreeSearchNode import MonteCarloTreeSearchNode
from State import State
import time

if __name__ == "__main__":
    env = gym.make("Sokoban-v0")
    env.reset()
    node = MonteCarloTreeSearchNode(state=State(env))
    node.state.print()
    while not node.state.is_game_over():
        time.sleep(5)
        node = node.best_action()
        node.state.print()
