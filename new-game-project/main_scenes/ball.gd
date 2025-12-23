extends CharacterBody2D
class_name Ball

@export var ball_speed := 20.0
@export var lifes := 3
@export var death_zone: DeathZone
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var start_position: Vector2
var speed_up_factor := 1.05

func _ready() -> void:
	start_position = global_position
	death_zone.life_lost.connect(on_life_lost)

func _physics_process(_delta):
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

func _start_ball() -> void:
	global_position = start_position
	randomize()

	var direction := Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, -0.1)
	).normalized()

	velocity = direction * ball_speed

func _on_life_lost():
	lifes -= 1
	if lifes == 0:
		pass
	else:
		reset_ball()
		
func reset_ball():
	position = start_position
	velocity = Vector2.ZERO
