extends CharacterBody2D
class_name Ball

signal life_lost

@export var ball_speed := 12.0
@export var lifes := 3
@export var death_zone: DeathZone
@export var hud: HUD  # Export this so you can drag the HUD node in the editor
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var start_position: Vector2
var speed_up_factor := 1.05
var last_collider_id

func _ready() -> void:
	# Try to get HUD if not exported
	if hud == null:
		hud = get_node_or_null("../HUD")
	
	if hud == null:
		push_error("HUD is NULL in Ball.gd - Please export the HUD reference")
		return

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

	# Special collision handling for paddle and bricks
	if collider is Paddle or collider is Brick:
		handle_collision_angle(collider)

func handle_collision_angle(collider) -> void:
	# Get current speed
	var current_speed := velocity.length()
	
	# Ensure minimum speed
	if current_speed < ball_speed:
		current_speed = ball_speed

	# Calculate collision offset (-1 to 1 from center)
	var collider_width: float = collider.get_width()
	var offset: float = (position.x - collider.position.x) / (collider_width * 0.5)
	offset = clamp(offset, -1.0, 1.0)

	# Calculate bounce angle
	var angle: float = offset * deg_to_rad(60.0)
	var direction: Vector2
	
	# Different direction calculation for paddle vs brick
	if collider is Paddle:
		# Paddle: bounce upwards
		direction = Vector2(sin(angle), -cos(angle))
		# Speed up when hitting paddle
		current_speed *= speed_up_factor
	elif collider is Brick:
		# Brick: use normal physics with slight randomness
		direction = velocity.normalized()
		direction = direction.rotated(deg_to_rad(randf_range(-15.0, 15.0)))
		
		# Ensure the ball bounces away from the brick
		if abs(direction.y) < 0.2:
			direction.y = -0.2 if direction.y >= 0 else 0.2
			direction = direction.normalized()

	# Apply new velocity
	velocity = direction.normalized() * current_speed
	
	# Speed limits
	var max_speed = ball_speed * 2.5
	var min_speed = ball_speed * 0.8
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	elif velocity.length() < min_speed:
		velocity = velocity.normalized() * min_speed

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
		if hud:
			hud.game_over()
	else:
		life_lost.emit()
		reset_ball()
		if hud:
			hud.set_lifes(lifes)
		
func reset_ball():
	position = start_position
	velocity = Vector2.ZERO
