import numpy as np

PENALTY_BOX_OFF_TARGET = -1
PENALTY_FOR_STEP = -0.1
REWARD_FINISHED = 10
DOWN = 0
UP = 1
RIGHT = 2
LEFT = 3
WALL = 0
FLOOR = 1
BOX_TARGET = 2
BOX_IN_TARGET = 3
BOX_OFF_TARGET = 4
PLAYER = 5

box_map = dict()


def point_value(room_state, point):
    return room_state[point[0]][point[1]]


def movable(box, dim_room, room_state):
    down, up, right, left = (box[0] + 1, box[1]), (box[0] - 1, box[1]), (box[0], box[1] + 1), (box[0], box[1] - 1)
    if (up_border(box) or down_border(box, dim_room)) and (left_border(box) or right_border(box)):
        return False
    elif (up_border(box) or down_border(box, dim_room)) and \
            (wall_or_box(right, room_state) or wall_or_box(left, room_state)):
        return False
    elif (left_border(box) or right_border(box, dim_room)) and \
            (wall_or_box(down, room_state) or wall_or_box(up, room_state)):
        return False
    elif (wall_or_box(down, room_state) and wall_or_box(right, room_state)) or \
            (wall_or_box(down, room_state) and wall_or_box(left, room_state)) or \
            (wall_or_box(up, room_state) and wall_or_box(right, room_state)) or \
            (wall_or_box(up, room_state) and wall_or_box(left, room_state)):
        return False
    else:
        return True


def up_border(point):
    return point[0] == 0


def down_border(point, dim_room):
    return point[0] == dim_room[0]


def left_border(point):
    return point[1] == 0


def right_border(point, dim_room):
    point[1] == dim_room[1]


def wall_or_box(point, room_state):
    value = point_value(room_state, point)
    return value == WALL or value == BOX_IN_TARGET or value == BOX_OFF_TARGET


def is_dead_end(env):
    for box, target in box_map.items():
        if point_value(env.room_state, box) != BOX_IN_TARGET and movable(box, env.dim_room, env.room_state):
            return False
    return True

# def boxes_from_targets_distance():
#     distance = 0
#     for box, target in box_map.items():
#         distance += np.linalg.norm(np.asarray(box) - np.asarray(target))
#     return distance


def update_box_position(old_box_position, new_box_position):
    box_map[new_box_position] = box_map[old_box_position]
    del box_map[old_box_position]


def initialize_box_map(box_mapping):
    for target, box in box_mapping.items():
        box_map[box] = target
