extends CharacterBody2D

class_name Ball

const VELOCITY_LIMIT = 40

@export var ball_speed = 200
@export var lifes = 3
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var speed_up_factor = 1.05
var start_position: Vector2

func _ready() -> void:
	start_position = position
	
func _physics_process(delta: float) -> void:
	move_and_collide(velocity * ball_speed * delta)
	
func _start_ball():
	position = start_position
	randomize()
	
	velocity = Vector2(randf_range(-1, 1), randf_range(-.1, -1)).normalized()
