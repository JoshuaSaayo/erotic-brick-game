extends CharacterBody2D
class_name Ball

signal life_lost

@export var ball_speed := 12.0
@export var lifes := 3
@export var death_zone: DeathZone
@export var hud: HUD

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
	global_position = start_position
	is_active = true
	velocity = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, -0.1)).normalized() * ball_speed

func stop() -> void:
	is_active = false
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
		hud.set_lifes(lifes)

func _on_game_state_changed(new_phase: GameState.Phase):
	match new_phase:
		GameState.Phase.GAMEPLAY:
			await get_tree().create_timer(0.5).timeout
			launch()
		GameState.Phase.POST_DIALOGUE, GameState.Phase.CUTSCENE:
			stop()
