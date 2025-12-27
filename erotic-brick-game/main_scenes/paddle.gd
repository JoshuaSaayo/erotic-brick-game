extends RigidBody2D
class_name Paddle

@export var speed := 800.0
@export var normal_width := 64.0  # Original width
@export var expanded_width := 96.0  # Expanded width
@export var expand_duration := 10.0  # How long expansion lasts (seconds)

@onready var ball := $"../ball" as Ball
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var expand_timer: Timer = $ExpandTimer  # Add Timer node!

var is_ball_launched := false
var direction := 0.0
var is_expanded := false

func _ready() -> void:
	ball.life_lost.connect(_on_ball_lost)
	GameState.phase_changed.connect(_on_game_state_changed)

	gravity_scale = 0
	linear_damp = 0
	angular_damp = 0
	lock_rotation = true

	# 🔥 IMPORTANT: Make collision shape unique
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()

	if expand_timer:
		expand_timer.timeout.connect(_on_expand_timer_timeout)

func _input(_event: InputEvent) -> void:
	if GameState.current_phase != GameState.Phase.GAMEPLAY:
		return
	
	if direction != 0 and !is_ball_launched:
		ball.launch()
		is_ball_launched = true

func _physics_process(_delta: float) -> void:
	if GameState.current_phase != GameState.Phase.GAMEPLAY:
		linear_velocity = Vector2.ZERO
		return
	
	direction = Input.get_axis("left", "right")
	linear_velocity.x = direction * speed

func expand():
	print("Paddle expanding!")
	
	if is_expanded:
		# Already expanded, reset timer
		if expand_timer:
			expand_timer.start(expand_duration)
		return
	
	is_expanded = true
	
	# Change paddle width
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var shape = collision_shape.shape as RectangleShape2D
		shape.size.x = expanded_width
		print("Paddle expanded to width: ", expanded_width)
	
	# Start timer to revert
	if expand_timer:
		expand_timer.start(expand_duration)
		print("Expand timer started for ", expand_duration, " seconds")
	
	# Visual feedback (optional)
	$Sprite2D.modulate = Color(0.8, 1.0, 0.8)  # Light green tint

func _on_expand_timer_timeout():
	print("Expand timer finished, reverting paddle")
	revert_expand()

func revert_expand():
	if not is_expanded:
		return
	
	is_expanded = false
	
	# Revert to normal width
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var shape = collision_shape.shape as RectangleShape2D
		shape.size.x = normal_width
		print("Paddle reverted to normal width: ", normal_width)
	
	# Remove visual effect
	$Sprite2D.modulate = Color.WHITE

func _on_ball_lost() -> void:
	is_ball_launched = false
	direction = 0.0
	linear_velocity = Vector2.ZERO

func _on_game_state_changed(new_phase: GameState.Phase):
	set_physics_process(new_phase == GameState.Phase.GAMEPLAY)

func get_width() -> float:
	if collision_shape and collision_shape.shape is RectangleShape2D:
		return (collision_shape.shape as RectangleShape2D).size.x
	return normal_width
