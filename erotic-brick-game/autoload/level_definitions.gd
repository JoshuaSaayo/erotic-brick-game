extends Node

static var level_1 = [
	[0, 1, 0],
]

static var level_2 = [
	[2, 2, 2, 2],
	[2, 3, 3, 2],
	[2, 2, 2, 2],
	[1, 1, 1, 1]
]

static var level_3 = [
	[3, 3, 3, 3],
	[2, 2, 2, 2],
	[1, 1, 1, 1],
	[2, 2, 2, 2]
]

# ... add all 9 levels

static func get_level_definition(level: int) -> Array:
	match level:
		1: return level_1
		2: return level_2
		# ... add cases for all levels
		_: return level_1
