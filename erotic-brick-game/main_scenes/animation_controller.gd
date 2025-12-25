extends Node2D

signal climax_finished

# UI References
@onready var anim: AnimationPlayer = $Node2D/anim
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var instruction_label: Label = $InstructionLabel

# Game State
var climax_played := false
var hold_timer := 0.0
var is_holding := false

# Constants
const HOLD_DURATION := 3.0
const MIN_SPEED := 1.0
const MAX_SPEED := 3.0

func _ready():
	# Setup animation
	anim.play("lewdscene")
	anim.speed_scale = MIN_SPEED
	
	# Setup UI
	progress_bar.visible = false
	progress_bar.max_value = HOLD_DURATION
	instruction_label.text = "Hold to speed up"

func _input(event):
	if event is InputEventMouseButton and not climax_played:
		_handle_mouse_input(event)

func _handle_mouse_input(event: InputEventMouseButton):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_holding()
		else:
			_stop_holding()

func _start_holding():
	is_holding = true
	hold_timer = 0.0
	progress_bar.visible = true
	progress_bar.value = 0
	instruction_label.text = "Keep holding..."

func _stop_holding():
	is_holding = false
	hold_timer = 0.0
	anim.speed_scale = MIN_SPEED
	progress_bar.visible = false
	if not climax_played:
		instruction_label.text = "Hold to speed up"

func _process(delta):
	if is_holding and not climax_played:
		_update_hold_progress(delta)

func _update_hold_progress(delta: float):
	hold_timer += delta
	var progress = hold_timer / HOLD_DURATION
	anim.speed_scale = MIN_SPEED + (MAX_SPEED - MIN_SPEED) * progress
	progress_bar.value = hold_timer
	
	if hold_timer >= HOLD_DURATION:
		_play_climax()

func _play_climax():
	climax_played = true
	is_holding = false
	anim.speed_scale = MIN_SPEED
	anim.stop()
	anim.play("climax")
	progress_bar.visible = false
	instruction_label.visible = false
	
	# Wait for climax to finish
	await anim.animation_finished
	
	# Signal completion
	climax_finished.emit()

# Helper for animation_manager
func get_climax_played() -> bool:
	return climax_played
