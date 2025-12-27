extends CharacterBody2D
class_name Ball

signal life_lost

@export var ball_speed := 12.0
@export var lifes := 3
@export var death_zone: DeathZone
@export var hud: HUD

var is_launched: bool = false
var start_position: Vector2
var speed_up_factor := 1.05
var is_active: bool = false

func _ready() -> void:
	hud.set_lifes(lifes)
	start_position = global_position
	death_zone.life_lost.connect(on_life_lost)
	GameState.phase_changed.connect(_on_game_state_changed)

func _physics_process(_delta: float) -> void:
	if not is_active or GameState.current_phase != GameState.Phase.GAMEPLAY:
		return
	
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		
		var collider = collision.get_collider()
		if collider is Brick:
			collider.decrease_level()
		
		_adjust_collision_angle(collider)
	
	# Ensure minimum speed - ADD THIS
	if velocity.length() < ball_speed * 0.5:
		velocity = velocity.normalized() * ball_speed

func _adjust_collision_angle(collider):
	if collider is Paddle:
		# Use paddle collision shape for width calculation
		var shape = collider.get_node("CollisionShape2D").shape if collider.has_node("CollisionShape2D") else null
		var paddle_width = shape.size.x if shape and shape.has_method("get_size") else 64.0
		
		var offset = clampf((position.x - collider.position.x) / (paddle_width * 0.5), -1.0, 1.0)
		var angle = offset * deg_to_rad(60.0)
		velocity = Vector2(sin(angle), -cos(angle)).normalized() * velocity.length() * speed_up_factor
	else:
		# Brick or other collision
		velocity = velocity.normalized().rotated(deg_to_rad(randf_range(-15.0, 15.0))) * velocity.length()
	
	velocity = velocity.normalized() * clampf(velocity.length(), ball_speed * 0.8, ball_speed * 2.5)

func launch() -> void:
	if is_launched:  # NEW: Prevent relaunching if already launched
		return
	
	global_position = start_position
	is_active = true
	is_launched = true  # NEW: Mark as launched
	velocity = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, -0.1)).normalized() * ball_speed

func stop() -> void:
	is_active = false
	is_launched = false  # NEW: Reset launch state when stopped
	velocity = Vector2.ZERO

func on_life_lost():
	lifes -= 1
	if lifes == 0:
		hud.game_over()
	else:
		life_lost.emit()
		position = start_position
		velocity = Vector2.ZERO
		is_active = false
		is_launched = false  # NEW: Reset launch state on life lost
		hud.set_lifes(lifes)

func _on_game_state_changed(new_phase: GameState.Phase):
	match new_phase:
		GameState.Phase.GAMEPLAY:
			# REMOVED auto-launch: await get_tree().create_timer(0.5).timeout
			# launch()  # Don't auto-launch anymore
			pass
		GameState.Phase.POST_DIALOGUE, GameState.Phase.CUTSCENE:
			stop()

func duplicate_ball():
	print("Duplicating ball!")
	
	# Create a new ball instance
	var new_ball = duplicate() as Ball
	get_parent().add_child(new_ball)
	
	# Initialize the new ball
	new_ball.is_launched = true
	new_ball.is_active = true
	new_ball.global_position = global_position + Vector2(10, 0)  # Offset slightly
	
	# Give it a slightly different direction (use velocity, not linear_velocity)
	var new_direction = velocity.normalized().rotated(deg_to_rad(30))
	new_ball.velocity = new_direction * velocity.length()
