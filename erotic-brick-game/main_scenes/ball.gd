extends CharacterBody2D
class_name Ball

signal life_lost
signal ball_stopped  # NEW: Signal when ball is stopped

@export var ball_speed := 12.0
@export var lifes := 3
@export var death_zone: DeathZone
@export var hud: HUD
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var start_position: Vector2
var speed_up_factor := 1.05
var last_collider_id
var is_active: bool = false  # NEW: Track if ball is active

func _ready() -> void:
	
	if hud == null:
		hud = get_node_or_null("../HUD")
	
	if hud == null:
		push_error("HUD is NULL in Ball.gd")

	hud.set_lifes(lifes)
	start_position = global_position
	death_zone.life_lost.connect(on_life_lost)
	
	# NEW: Listen for gameplay state changes
	GameState.phase_changed.connect(_on_game_state_changed)

func enable_gameplay():
	print("Ball: Gameplay enabled")
	set_physics_process(true)

func disable_gameplay():
	print("Ball: Gameplay disabled")
	set_physics_process(false)
	velocity = Vector2.ZERO
	is_active = false

func _physics_process(_delta: float) -> void:
	# Only process if active and in gameplay
	if not is_active or GameState.current_phase != GameState.Phase.GAMEPLAY:
		return
	
	var collision := move_and_collide(velocity)
	if not collision:
		return

	var collider := collision.get_collider()
	var normal := collision.get_normal()
	velocity = velocity.bounce(normal)

	if collider is Brick:
		collider.decrease_level()
		handle_collision_angle(collider)
	elif collider is Paddle:
		handle_collision_angle(collider)

func handle_collision_angle(collider):
	# (Keep your existing collision angle code)
	var current_speed := velocity.length()
	if current_speed < ball_speed:
		current_speed = ball_speed

	var collider_width: float = collider.get_width()
	var offset: float = (position.x - collider.position.x) / (collider_width * 0.5)
	offset = clamp(offset, -1.0, 1.0)

	var angle: float = offset * deg_to_rad(60.0)
	var direction: Vector2
	
	if collider is Paddle:
		direction = Vector2(sin(angle), -cos(angle))
		current_speed *= speed_up_factor
	elif collider is Brick:
		direction = velocity.normalized()
		direction = direction.rotated(deg_to_rad(randf_range(-15.0, 15.0)))
		
		if abs(direction.y) < 0.2:
			direction.y = -0.2 if direction.y >= 0 else 0.2
			direction = direction.normalized()

	velocity = direction.normalized() * current_speed
	
	var max_speed = ball_speed * 2.5
	var min_speed = ball_speed * 0.8
	
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	elif velocity.length() < min_speed:
		velocity = velocity.normalized() * min_speed

func start_ball() -> void:  # Public function - NO underscore
	global_position = start_position
	randomize()
	
	is_active = true
	
	var direction := Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, -0.1)
	).normalized()
	
	velocity = direction * ball_speed
	print("Ball started with velocity: ", velocity)

func stop_ball() -> void:  # NEW: Stop ball function
	is_active = false
	velocity = Vector2.ZERO
	ball_stopped.emit()

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
	is_active = false

func _on_game_state_changed(new_phase: GameState.Phase):
	match new_phase:
		GameState.Phase.GAMEPLAY:
			# Start the ball when gameplay begins
			await get_tree().create_timer(0.5).timeout  # Small delay
			start_ball()
		GameState.Phase.POST_DIALOGUE, GameState.Phase.CUTSCENE:
			# Stop ball during dialogue/cutscene
			stop_ball()
