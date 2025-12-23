extends CharacterBody2D
class_name Ball

signal life_lost

@export var ball_speed := 12.0
@export var lifes := 3
@export var death_zone: DeathZone
@export var hud: HUD
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var start_position: Vector2
var speed_up_factor := 1.05
var last_collider_id

func _ready() -> void:
	hud.set_lifes(lifes)
	start_position = global_position
	death_zone.life_lost.connect(on_life_lost)

func _physics_process(_delta: float) -> void:
	var collision := move_and_collide(velocity)
	if not collision:
		return

	var collider := collision.get_collider()
	var normal := collision.get_normal()

	# Base bounce
	velocity = velocity.bounce(normal)

	# Brick logic
	if collider is Brick:
		collider.decrease_level()

	# Direction shaping ONLY for paddle hits
	if collider is Paddle:
		apply_paddle_angle(collider)

func apply_paddle_angle(paddle: Paddle) -> void:
	var speed: float = velocity.length()

	var paddle_width: float = paddle.get_width()
	var offset: float = (position.x - paddle.position.x) / (paddle_width * 0.5)
	offset = clamp(offset, -1.0, 1.0)

	var angle: float = offset * deg_to_rad(60.0)
	var direction: Vector2 = Vector2(sin(angle), -cos(angle))

	speed *= speed_up_factor
	velocity = direction.normalized() * speed

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

func ball_collision(collider) -> void:
	var speed: float = velocity.length()

	# Safety clamp
	if speed < ball_speed:
		speed = ball_speed

	var collider_width: float = collider.get_width()
	var offset: float = (position.x - collider.position.x) / (collider_width * 0.5)
	offset = clamp(offset, -1.0, 1.0)

	var angle: float = offset * deg_to_rad(60.0)
	var direction: Vector2 = Vector2(sin(angle), -cos(angle))

	# Small randomness on bricks
	if collider is Brick:
		direction = direction.rotated(deg_to_rad(randf_range(-8.0, 8.0)))

	# Speed-up on paddle
	if collider is Paddle:
		speed *= speed_up_factor

	velocity = direction.normalized() * speed
