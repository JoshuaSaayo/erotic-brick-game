extends RigidBody2D
class_name Paddle

@export var speed := 800.0
@onready var ball := $"../ball" as Ball

var direction := 0.0
var is_ball_started := false

func _ready() -> void:
	ball.life_lost.connect(on_ball_lost)
	GameState.phase_changed.connect(_on_game_state_changed)
	
	gravity_scale = 0
	linear_damp = 0
	angular_damp = 0
	lock_rotation = true

func _input(_event: InputEvent) -> void:
	if GameState.current_phase != GameState.Phase.GAMEPLAY:
		return
	
	if direction != 0 and !is_ball_started:
		ball.launch()
		is_ball_started = true

func _physics_process(_delta: float) -> void:
	if GameState.current_phase != GameState.Phase.GAMEPLAY:
		linear_velocity = Vector2.ZERO
		return
	
	direction = Input.get_axis("left", "right")
	linear_velocity.x = direction * speed

func on_ball_lost() -> void:
	is_ball_started = false
	direction = 0.0
	linear_velocity = Vector2.ZERO

func get_width() -> float:
	return $CollisionShape2D.shape.get_rect().size.x

func _on_game_state_changed(new_phase: GameState.Phase):
	set_physics_process(new_phase == GameState.Phase.GAMEPLAY)
