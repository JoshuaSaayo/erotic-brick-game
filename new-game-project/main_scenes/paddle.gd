extends RigidBody2D
class_name Paddle

@export var speed := 800.0
@export var camera: Camera2D

var direction := 0.0
var camera_rect: Rect2
var half_paddle_width: float
var is_ball_started = false

@onready var ball = $"../ball" as Ball
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	ball.life_lost.connect(on_ball_lost)
	camera_rect = camera.get_viewport_rect()
	half_paddle_width = collision_shape_2d.shape.get_rect().size.x * 0.5 * scale.x

func _input(event: InputEvent) -> void:
	if direction != 0 and !is_ball_started:
		ball._start_ball()
		is_ball_started = true

func _physics_process(_delta: float) -> void:
	# Input
	direction = Input.get_axis("left", "right")

	# Movement
	linear_velocity.x = direction * speed

	# Camera bounds
	var camera_start_x = camera.global_position.x - camera_rect.size.x * 0.5
	var camera_end_x = camera_start_x + camera_rect.size.x

	# Clamp position safely
	if global_position.x - half_paddle_width < camera_start_x:
		global_position.x = camera_start_x + half_paddle_width
		linear_velocity.x = 0
	elif global_position.x + half_paddle_width > camera_end_x:
		global_position.x = camera_end_x - half_paddle_width
		linear_velocity.x = 0

func on_ball_lost():
	is_ball_started = false
	direction = 0.0
