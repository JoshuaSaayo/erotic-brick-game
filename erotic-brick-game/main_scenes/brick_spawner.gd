extends Node
class_name BrickSpawner

signal level_completed
signal bricks_destroyed(count: int, total: int)  # NEW: Signal for progress

@export var brick_scene: PackedScene
@export var margin: Vector2 = Vector2(8, 8)
@export var spawn_start: Marker2D

@onready var ball: Ball = $"../Arcade/ball"

var brick_count: int = 0
var destroyed_count: int = 0  # NEW: Track destroyed bricks
var half_bricks_destroyed: bool = false  # NEW: Track if half are destroyed

func _ready() -> void:
	print("BrickSpawner: Ready for level ", GameState.current_level)
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
	
	# Get brick layout from GameData
	var brick_layout = GameData.get_brick_layout(GameState.current_level)
	if brick_layout.is_empty():
		print("Warning: No brick layout for level ", GameState.current_level)
		return
	
	spawn_from_definition(brick_layout)
	print("BrickSpawner: Spawned ", brick_count, " bricks")

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
			brick.brick_destroyed.connect(_on_brick_destroyed)

			brick_count += 1

func _on_brick_destroyed():
	destroyed_count += 1
	brick_count -= 1
	
	print("Bricks destroyed: ", destroyed_count, "/", destroyed_count + brick_count)
	
	# Emit progress signal
	bricks_destroyed.emit(destroyed_count, destroyed_count + brick_count)
	
	# Check if half bricks are destroyed
	if not half_bricks_destroyed and destroyed_count >= (destroyed_count + brick_count) / 2:
		half_bricks_destroyed = true
		print("Half of bricks destroyed! Triggering character reaction")
		# Signal for character reaction
		get_tree().call_group("character", "on_half_bricks_destroyed")
	
	if brick_count == 0:
		print("All bricks destroyed!")
		ball.stop()
		level_completed.emit()
