extends RigidBody2D
class_name Paddle

@export var speed := 800.0

var direction := 0.0
var is_ball_started := false

@onready var ball := $"../ball" as Ball

func _ready() -> void:
	ball.life_lost.connect(on_ball_lost)

	# Physics sanity
	gravity_scale = 0
	linear_damp = 0
	angular_damp = 0
	lock_rotation = true

func _input(_event: InputEvent) -> void:
	if direction != 0 and !is_ball_started:
		ball._start_ball()
		is_ball_started = true

func _physics_process(_delta: float) -> void:
	direction = Input.get_axis("left", "right")
	linear_velocity.x = direction * speed

func on_ball_lost() -> void:
	is_ball_started = false
	direction = 0.0

func get_width() -> float:
	return $CollisionShape2D.shape.get_rect().size.x
