extends Node

class_name  BrickSpawner

const COLUMNS = 5
const ROWS = 5

@onready var ball: Ball = $"../../ball" as Ball
@onready var hud: HUD = $"../../HUD" as HUD

@export var brick_scene: PackedScene
@export var margin: Vector2 = Vector2(8,8)
@export var spawn_start: Marker2D

var brick_count = 0

func _ready() -> void:
	spawn_from_definition(LevelDefinitions.level_1)

func spawn():
	var test_brick = brick_scene.instantiate() as Brick
	add_child(test_brick)
	var brick_size = test_brick.get_size()
	test_brick.queue_free()
	
	var row_width = brick_size.x * COLUMNS + margin.x * (COLUMNS - 1)
	var spawn_position_x = (-row_width + brick_size.x + margin.x) / 2
	var spawn_position_y = spawn_start.position.y 
	
	for i in ROWS:
		for j in COLUMNS:
			var brick = brick_scene.instantiate() as Brick
			add_child(brick)
			brick.set_level(ROWS - i)
			var x = spawn_position_x + j * (margin.x + brick.get_size().x)
			var y = spawn_position_y + i * (margin.y + brick.get_size().y)
			brick.set_position(Vector2(x,y))
			brick.brick_destroyed.connect(on_brick_destroyed)
			
			
func spawn_from_definition(level_definition):
	var test_brick = brick_scene.instantiate() as Brick
	add_child(test_brick)
	var brick_size = test_brick.get_size()
	test_brick.queue_free()
	var rows = level_definition.size()
	var columns = level_definition[0].size()
	
	var row_width = brick_size.x * columns + margin.x * (columns - 1)
	var spawn_position_x = (-row_width + brick_size.x + margin.x) / 2
	var spawn_position_y = spawn_start.position.y 
	
	for i in rows:
		for j in columns:
			if level_definition[i][j] == 0:
				continue
				
			var brick = brick_scene.instantiate() as Brick
			add_child(brick)
			brick.set_level(level_definition[i][j])
			var x = spawn_position_x + j * (margin.x + brick.get_size().x)
			var y = spawn_position_y + i * (margin.y + brick.get_size().y)
			brick.set_position(Vector2(x,y))
			brick.brick_destroyed.connect(on_brick_destroyed)
	
func on_brick_destroyed():
	brick_count -= 1
	if brick_count == 0:
		ball.stop_ball
		LevelDefinitions.current_level = 2
	
			
