extends CanvasLayer

class_name HUD

@export var lifes_label: Label
@onready var game_lost_container: CenterContainer = $GameLostContainer
@onready var speech_bubble: Panel = $SpeechBubble
@onready var speech: Label = $SpeechBubble/Speech
@onready var next_btn: Button = $NextBtn

func _ready():
	speech_bubble.hide()
	next_btn.hide()
	
	DialogueManager.dialogue_line.connect(show_line)
	DialogueManager.dialogue_finished.connect(on_dialogue_finished)
	GameState.phase_changed.connect(on_phase_changed)
	
	next_btn.pressed.connect(DialogueManager.show_next_line)

func show_line(text: String, character: String) -> void:
	speech.text = text
	speech_bubble.show()
	next_btn.show()

func on_dialogue_finished() -> void:
	speech_bubble.hide()
	next_btn.hide()

func on_phase_changed(new_phase: GameState.Phase):
	if new_phase == GameState.Phase.GAMEPLAY:
		# Enable game controls
		pass
	elif new_phase == GameState.Phase.POST_DIALOGUE:
		# Disable game controls
		pass

func hide_bubble() -> void:
	speech_bubble.hide()
	
func set_lifes(lifes: int):
	lifes_label.text = "Lifes: %d" % lifes

func game_over():
	game_lost_container.show()

func _on_game_lost_btn_pressed() -> void:
	get_tree().reload_current_scene()
