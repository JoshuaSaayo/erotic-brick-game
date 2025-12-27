extends Node
class_name BrickSpawner

signal level_completed
signal bricks_destroyed(count: int, total: int)

@export var brick_scene: PackedScene
@export var margin: Vector2 = Vector2(8, 8)
@export var spawn_start: Marker2D
@export var powerup_scene: PackedScene
@export var powerup_chance := 1  # 25% chance
@onready var ball: Ball = $"../Arcade/ball"

var brick_count: int = 0
var destroyed_count: int = 0
var half_bricks_destroyed: bool = false
var last_destroyed_brick_position: Vector2

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
	
	# Clear existing bricks and powerups
	for child in get_children():
		if child is Brick or child is PowerUp:
			child.queue_free()
	
	brick_count = 0
	destroyed_count = 0
	half_bricks_destroyed = false
	
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
			
			# SIMPLE CONNECTION - no .bind() needed
			brick.brick_destroyed.connect(_on_brick_destroyed)

			brick_count += 1

# FIXED: Accept Brick parameter
func _on_brick_destroyed(brick: Brick):
	print("Brick destroyed at: ", brick.global_position)
	last_destroyed_brick_position = brick.global_position
	
	# Try to spawn powerup (ADD THIS!)
	_try_spawn_powerup(brick.global_position)
	
	destroyed_count += 1
	brick_count -= 1

	print("Bricks destroyed: ", destroyed_count, "/", destroyed_count + brick_count)
	bricks_destroyed.emit(destroyed_count, destroyed_count + brick_count)

	# Check if half bricks are destroyed
	if not half_bricks_destroyed and destroyed_count >= (destroyed_count + brick_count) / 2:
		half_bricks_destroyed = true
		print("Half of bricks destroyed! Triggering character reaction")
		get_tree().call_group("character", "on_half_bricks_destroyed")
	
	if brick_count == 0:
		print("All bricks destroyed!")
		ball.stop()
		level_completed.emit()

func _try_spawn_powerup(position: Vector2):
	if randf() > powerup_chance:
		print("No powerup spawned (failed chance roll)")
		return
	
	if powerup_scene:
		print("=== SPAWNING POWERUP ===")
		
		# Debug: Show where powerup would spawn
		var debug_circle = Sprite2D.new()
		var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		image.fill(Color.RED)
		var texture = ImageTexture.create_from_image(image)
		debug_circle.texture = texture
		debug_circle.position = position
		debug_circle.z_index = 100
		add_child(debug_circle)
		
		# Remove debug after 1 second
		await get_tree().create_timer(1.0).timeout
		debug_circle.queue_free()
		
		# Spawn actual powerup
		var powerup: PowerUp = powerup_scene.instantiate()
		add_child(powerup)
		powerup.global_position = position
		powerup.type = randi() % PowerUp.Type.size()
		
		print("Powerup spawned at: ", position, " type: ", powerup.type)
	else:
		print("ERROR: powerup_scene is not assigned!")
