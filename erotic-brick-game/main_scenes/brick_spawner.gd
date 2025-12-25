extends Node
class_name BrickSpawner

@export var brick_scene: PackedScene
@export var margin: Vector2 = Vector2(8, 8)
@export var spawn_start: Marker2D

@onready var ball: Ball = $"../Arcade/ball"

var brick_count: int = 0

func _ready() -> void:
	# Connect to game state
	GameState.phase_changed.connect(_on_game_state_changed)
	
	if GameState.current_phase == GameState.Phase.GAMEPLAY:
		spawn_bricks()

func _on_game_state_changed(new_phase: GameState.Phase):
	if new_phase == GameState.Phase.GAMEPLAY:
		spawn_bricks()

func spawn_bricks():
	print("BrickSpawner: Spawning bricks for level ", GameState.current_level)
	
	# Clear existing bricks
	for child in get_children():
		if child is Brick:
			child.queue_free()
	
	brick_count = 0
	
	# Get level definition based on current level
	var level_def = _get_level_definition(GameState.current_level)
	spawn_from_definition(level_def)
	
	print("BrickSpawner: Spawned ", brick_count, " bricks")

func _get_level_definition(level: int) -> Array:
	match level:
		1: return LevelDefinitions.level_1
		2: return LevelDefinitions.level_2
		3: return LevelDefinitions.level_3
		4: return LevelDefinitions.level_4
		5: return LevelDefinitions.level_5
		6: return LevelDefinitions.level_6
		7: return LevelDefinitions.level_7
		8: return LevelDefinitions.level_8
		9: return LevelDefinitions.level_9
		_: return LevelDefinitions.level_1

func spawn_from_definition(level_definition: Array) -> void:
	var test_brick: Brick = brick_scene.instantiate()
	add_child(test_brick)
	var brick_size: Vector2 = test_brick.get_size()
	test_brick.queue_free()

	var rows: int = level_definition.size()
	var columns: int = level_definition[0].size()

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
	print("Bricks remaining: ", brick_count)
	
	if brick_count == 0:
		print("All bricks destroyed! Ending level...")
		ball.stop()
		GameFlowManager.end_level()
