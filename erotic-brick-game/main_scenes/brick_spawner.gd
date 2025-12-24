extends Node
class_name BrickSpawner

@export var brick_scene: PackedScene
@export var margin: Vector2 = Vector2(8, 8)
@export var spawn_start: Marker2D

@onready var ball: Ball = $"../../ball"
@onready var hud: HUD = $"../../HUD"

var brick_count: int = 0

func _ready() -> void:
	spawn_from_definition(LevelDefinitions.level_1)

func spawn_from_definition(level_definition: Array) -> void:
	# --- Measure brick ---
	var test_brick: Brick = brick_scene.instantiate()
	add_child(test_brick)
	var brick_size: Vector2 = test_brick.get_size()
	test_brick.queue_free()

	var rows: int = level_definition.size()
	var columns: int = level_definition[0].size()

	# --- Anchor position (TOP-LEFT of arcade screen) ---
	var start_x: float = spawn_start.global_position.x
	var start_y: float = spawn_start.global_position.y

	for i in range(rows):
		for j in range(columns):
			var level: int = level_definition[i][j]
			if level == 0:
				continue

			var brick: Brick = brick_scene.instantiate()
			add_child(brick)

			brick.set_level(level)

			var x: float = start_x + j * (brick_size.x + margin.x)
			var y: float = start_y + i * (brick_size.y + margin.y)

			brick.global_position = Vector2(x, y)
			brick.brick_destroyed.connect(on_brick_destroyed)

			brick_count += 1

func on_brick_destroyed() -> void:
	brick_count -= 1
	if brick_count == 0:
		ball.stop_ball()
		LevelDefinitions.current_level += 1
