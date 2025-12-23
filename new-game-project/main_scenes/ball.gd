extends CharacterBody2D
class_name Ball

signal life_lost

@export var ball_speed := 20.0
@export var lifes := 3
@export var death_zone: DeathZone
@export var hud: HUD
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var start_position: Vector2
var speed_up_factor := 1.05

func _ready() -> void:
	hud.set_lifes(lifes)
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

func on_life_lost():
	lifes -= 1
	if lifes == 0:
		hud.game_over()
	else:
		life_lost.emit()
		reset_ball()
		hud.set_lifes(lifes)
		
func reset_ball():
	position = start_position
	velocity = Vector2.ZERO
