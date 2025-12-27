extends Node2D

signal animation_completed

# UI References (add these nodes to your animation scene)
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var instruction_label: Label = $InstructionLabel
@onready var anim: AnimationPlayer = $Node2D/anim

# Game State
var climax_played := false
var hold_timer := 0.0
var is_holding := false

# Constants
const HOLD_DURATION := 3.0
const MIN_SPEED := 1.0
const MAX_SPEED := 3.0

func _ready():
	# Setup UI
	if progress_bar:
		progress_bar.visible = false
		progress_bar.max_value = HOLD_DURATION
	
	if instruction_label:
		instruction_label.text = "Hold to speed up"
	
	# Start animation
	if anim:
		anim.play("lewdscene")
		anim.speed_scale = MIN_SPEED

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
	
	if progress_bar:
		progress_bar.visible = true
		progress_bar.value = 0
	
	if instruction_label:
		instruction_label.text = "Keep holding..."

func _stop_holding():
	is_holding = false
	hold_timer = 0.0
	
	if anim:
		anim.speed_scale = MIN_SPEED
	
	if progress_bar:
		progress_bar.visible = false
	
	if instruction_label and not climax_played:
		instruction_label.text = "Hold to speed up"

func _process(delta):
	if is_holding and not climax_played:
		_update_hold_progress(delta)

func _update_hold_progress(delta: float):
	hold_timer += delta
	
	if anim:
		var progress = hold_timer / HOLD_DURATION
		anim.speed_scale = MIN_SPEED + (MAX_SPEED - MIN_SPEED) * progress
	
	if progress_bar:
		progress_bar.value = hold_timer
	
	if hold_timer >= HOLD_DURATION:
		_play_climax()

func _play_climax():
	climax_played = true
	is_holding = false
	
	if anim:
		anim.speed_scale = MIN_SPEED
		anim.stop()
		anim.play("climax")
		await anim.animation_finished
	
	# Hide UI
	if progress_bar:
		progress_bar.visible = false
	
	if instruction_label:
		instruction_label.visible = false
	
	# Wait a moment to let players see the climax animation finish
	await get_tree().create_timer(1.5).timeout
	
	# Fade to black before signaling completion
	TransitionManager.fade_in(1.0)
	await TransitionManager.fade_in_completed
	
	# Signal completion
	emit_signal("animation_completed")
