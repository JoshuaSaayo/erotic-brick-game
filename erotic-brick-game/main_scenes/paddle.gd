extends RigidBody2D
class_name Paddle

@export var speed := 800.0

var direction := 0.0
var is_ball_started := false

@onready var ball := $"../ball" as Ball

func _ready() -> void:
	add_to_group("gameplay")
	ball.life_lost.connect(on_ball_lost)
	
	# Connect to game state changes
	GameState.phase_changed.connect(_on_game_state_changed)
	
	# Physics sanity
	gravity_scale = 0
	linear_damp = 0
	angular_damp = 0
	lock_rotation = true
	
	# Initially disable if not in gameplay
	if GameState.current_phase != GameState.Phase.GAMEPLAY:
		set_physics_process(false)

func enable_gameplay():
	print("Paddle: Gameplay enabled")
	set_physics_process(true)
	set_process_input(true)

func disable_gameplay():
	print("Paddle: Gameplay disabled")
	set_physics_process(false)
	set_process_input(false)
	linear_velocity = Vector2.ZERO
	is_ball_started = false

func _input(_event: InputEvent) -> void:
	# Only allow ball start during gameplay
	if GameState.current_phase != GameState.Phase.GAMEPLAY:
		return
	
	if direction != 0 and !is_ball_started:
		ball.start_ball()  # CHANGED: Remove underscore, use public function
		is_ball_started = true

func _physics_process(_delta: float) -> void:
	# Only move during gameplay
	if GameState.current_phase != GameState.Phase.GAMEPLAY:
		linear_velocity = Vector2.ZERO
		return
	
	direction = Input.get_axis("left", "right")
	linear_velocity.x = direction * speed

func _on_game_state_changed(new_phase: GameState.Phase):
	match new_phase:
		GameState.Phase.GAMEPLAY:
			# Enable paddle when gameplay starts
			set_physics_process(true)
			print("Paddle: Gameplay enabled")
		GameState.Phase.POST_DIALOGUE, GameState.Phase.CUTSCENE:
			# Disable paddle during dialogue/cutscene
			set_physics_process(false)
			linear_velocity = Vector2.ZERO
			print("Paddle: Disabled for dialogue/cutscene")

func on_ball_lost() -> void:
	is_ball_started = false
	direction = 0.0
	linear_velocity = Vector2.ZERO

func get_width() -> float:
	return $CollisionShape2D.shape.get_rect().size.x
