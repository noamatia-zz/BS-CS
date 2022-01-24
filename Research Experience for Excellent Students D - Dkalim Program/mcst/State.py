import numpy as np
import copy
from pandas import *

# movement directions
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

# board elements
WALL = 0
FLOOR = 1
TARGET = 2
BOX_OFF_TARGET = 3
BOX_ON_TARGET = 4
PLAYER_OFF_TARGET = 5
PLAYER_ON_TARGET = 6

# image elements
WALLS = 0
EMPTY_GOAL_SQUARES = 1
BOXES_ON_EMPTY_SQUARES = 2
BOXES_ON_GOAL_SQUARES = 3
PLAYER_REACHABLE_CELLS = 4
PLAYER_REACHABLE_CELLS_ON_GOAL_SQUARES = 5


class State:
    def __init__(self, env):
        self.board_dimensions = env.dim_room
        # walls, floors and targets
        self.board = copy.deepcopy(env.room_fixed)
        self.boxes = []
        self.targets = []
        for target, box in env.box_mapping.items():
            self.boxes.append(copy.deepcopy(box))
            self.targets.append(copy.deepcopy(target))
        self.player = copy.deepcopy(env.player_position)
        self.n_boxes = env.num_boxes
        self.n_boxes_on_target = env.boxes_on_target
        self.reachable_cells = np.zeros(tuple(self.board_dimensions), int)
        self.update_reachable_cells(tuple(self.player))
        self.legal_actions = []
        self.update_legal_actions()
        # network input
        self.image = np.zeros(tuple([6, self.board_dimensions[0], self.board_dimensions[1]]), int)
        self.init_image_walls()
        self.update_image()
        return

    def init_image_walls(self):
        for i in range(self.board_dimensions[0]):
            for j in range(self.board_dimensions[1]):
                if self.board[i][j] == WALL:
                    self.image[WALLS][i][j] = 1

    def update_image(self):
        for i in range(EMPTY_GOAL_SQUARES, PLAYER_REACHABLE_CELLS_ON_GOAL_SQUARES + 1):
            self.image[i] = np.zeros(tuple(self.board_dimensions), int)
        for box in self.boxes:
            if self.board[box[0]][box[1]] == TARGET:
                self.image[BOXES_ON_GOAL_SQUARES][box[0]][box[1]] = 1
            else:
                self.image[BOXES_ON_EMPTY_SQUARES][box[0]][box[1]] = 1
        self.image[PLAYER_REACHABLE_CELLS] = copy.deepcopy(self.reachable_cells)
        for target in self.targets:
            if self.image[BOXES_ON_GOAL_SQUARES][target[0]][target[1]] != 1:
                self.image[EMPTY_GOAL_SQUARES][target[0]][target[1]] = 1
            if self.image[PLAYER_REACHABLE_CELLS][target[0]][target[1]] == 1:
                self.image[PLAYER_REACHABLE_CELLS][target[0]][target[1]] = 0
                self.image[PLAYER_REACHABLE_CELLS_ON_GOAL_SQUARES][target[0]][target[1]] = 1

    def update_reachable_cells(self, player):
        self.reachable_cells[player[0]][player[1]] = 1
        down, up, right, left = (player[0] + 1, player[1]), (player[0] - 1, player[1]), (player[0], player[1] + 1), (player[0], player[1] - 1)
        # player is not at the down border of the board, it has floor down to it and didn't visit there before
        if player[0] != self.board_dimensions[0] and not self.is_wall_or_box(down) and self.reachable_cells[down[0]][down[1]] != 1:
            self.update_reachable_cells(down)
        # player is not at the up border of the board, it has floor up to it and didn't visit there before
        if player[0] != 0 and not self.is_wall_or_box(up) and self.reachable_cells[up[0]][up[1]] != 1:
            self.update_reachable_cells(up)
        # player is not at the right border of the board, it has floor right to it and didn't visit there before
        if player[1] != self.board_dimensions[1] and not self.is_wall_or_box(right) and self.reachable_cells[right[0]][right[1]] != 1:
            self.update_reachable_cells(right)
        # player is not at the left border of the board, it has floor left to it and didn't visit there before
        if player[1] != 0 and not self.is_wall_or_box(left) and self.reachable_cells[left[0]][left[1]] != 1:
            self.update_reachable_cells(left)

    def update_legal_actions(self):
        for box in self.boxes:
            down, up, right, left = (box[0] + 1, box[1]), (box[0] - 1, box[1]), (box[0], box[1] + 1), (box[0], box[1] - 1)
            # box is not at the down\up border of the board and has floor down\up to it
            if box[0] != self.board_dimensions[0] and (not self.is_wall_or_box(down)) and box[0] != 0 and (not self.is_wall_or_box(up)):
                # down to the box is reachable
                if self.reachable_cells[down[0]][down[1]] == 1:
                    # player can push the box up
                    self.legal_actions.append((down, UP))
                # up to the box is reachable
                if self.reachable_cells[up[0]][up[1]] == 1:
                    # player can push the box down
                    self.legal_actions.append((up, DOWN))
            # box is not at the right\left border of the board and has floor right\left to it
            if box[1] != self.board_dimensions[1] and (not self.is_wall_or_box(right)) and box[1] != 0 and (not self.is_wall_or_box(left)):
                # right to the box is reachable
                if self.reachable_cells[right[0]][right[1]] == 1:
                    # player can push the box left
                    self.legal_actions.append((right, LEFT))
                # left to the box is reachable
                if self.reachable_cells[left[0]][left[1]] == 1:
                    # player can push the box right
                    self.legal_actions.append((left, RIGHT))

    def get(self, point):
        return self.board[point[0]][point[1]]

    def is_box(self, point):
        for box in self.boxes:
            if point == box:
                return True
        return False

    def is_wall_or_box(self, point):
        return self.get(point) == WALL or self.is_box(point)

    def move(self, action):
        next_state = copy.deepcopy(self)
        player = action[0]
        direction = action[1]
        down, up, right, left = (player[0] + 1, player[1]), (player[0] - 1, player[1]), (player[0], player[1] + 1), (player[0], player[1] - 1)
        # pushing box down
        if direction == DOWN:
            down_down = (down[0] + 1, down[1])
            # pushing box from target
            if next_state.get(down) == TARGET:
                next_state.n_boxes_on_target -= 1
            # pushing box to target
            if next_state.get(down_down) == TARGET:
                next_state.n_boxes_on_target += 1
            # updating box position
            next_state.update_box(down, down_down)
            # updating player position
            next_state.player = list(down)
        # pushing box up
        if direction == UP:
            up_up = (up[0] - 1, up[1])
            # pushing box from target
            if next_state.get(up) == TARGET:
                next_state.n_boxes_on_target -= 1
            # pushing box to target
            if next_state.get(up_up) == TARGET:
                next_state.n_boxes_on_target += 1
            # updating box position
            next_state.update_box(up, up_up)
            # updating player position
            next_state.player = list(up)
        # pushing box right
        if direction == RIGHT:
            right_right = (right[0], right[1] + 1)
            # pushing box from target
            if next_state.get(right) == TARGET:
                next_state.n_boxes_on_target -= 1
            # pushing box to target
            if next_state.get(right_right) == TARGET:
                next_state.n_boxes_on_target += 1
            # updating box position
            next_state.update_box(right, right_right)
            # updating player position
            next_state.player = list(right)
        # pushing box left
        if direction == LEFT:
            left_left = (left[0], left[1] - 1)
            # pushing box from target
            if next_state.get(left) == TARGET:
                next_state.n_boxes_on_target -= 1
            # pushing box to target
            if next_state.get(left_left) == TARGET:
                next_state.n_boxes_on_target += 1
            # updating box position
            next_state.update_box(left, left_left)
            # updating player position
            next_state.player = list(left)
        next_state.reachable_cells = np.zeros(tuple(next_state.board_dimensions), int)
        next_state.update_reachable_cells(tuple(next_state.player))
        next_state.legal_actions = []
        next_state.update_legal_actions()
        next_state.update_image()
        return next_state

    def update_box(self, old_point, new_point):
        self.boxes.remove(old_point)
        self.boxes.append(new_point)

    def is_game_over(self):
        return len(self.legal_actions) == 0 or self.is_goal()

    def is_goal(self):
        return self.n_boxes_on_target == self.n_boxes

    def game_result(self):
        if self.is_goal():
            return 1
        elif len(self.legal_actions) == 0:
            return -1
        else:
            return 0

    def print(self):
        board = copy.deepcopy(self.board)
        for box in self.boxes:
            if self.get(box) == FLOOR:
                board[box[0]][box[1]] = BOX_OFF_TARGET
            else:
                board[box[0]][box[1]] = BOX_ON_TARGET
        if self.get(self.player) == FLOOR:
            board[self.player[0]][self.player[1]] = PLAYER_OFF_TARGET
        else:
            board[self.player[0]][self.player[1]] = PLAYER_ON_TARGET
        new_board = []
        for i in range(self.board_dimensions[0]):
            row = []
            for j in range(self.board_dimensions[1]):
                if board[i][j] == WALL:
                    row.append('W')
                elif board[i][j] == FLOOR:
                    row.append(' ')
                elif board[i][j] == TARGET:
                    row.append('T')
                elif board[i][j] == BOX_OFF_TARGET:
                    row.append('b')
                elif board[i][j] == BOX_ON_TARGET:
                    row.append('B')
                elif board[i][j] == PLAYER_OFF_TARGET:
                    row.append('p')
                elif board[i][j] == PLAYER_ON_TARGET:
                    row.append('P')
            new_board.append(row)
        print("*******************************")
        print(DataFrame(new_board))
        print("*******************************")
