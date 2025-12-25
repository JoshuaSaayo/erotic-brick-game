extends CanvasLayer

class_name HUD

@export var lifes_label: Label
@onready var game_lost_container: CenterContainer = $GameLostContainer
@onready var speech_bubble: Panel = $SpeechBubble
@onready var speech: Label = $SpeechBubble/Speech

func _ready():
	speech_bubble.hide()

	Dialogues.dialogue_line.connect(show_line)
	Dialogues.dialogue_finished.connect(hide_bubble)

func show_line(text: String) -> void:
	speech.text = text
	speech_bubble.show()

func hide_bubble() -> void:
	speech_bubble.hide()
	
func set_lifes(lifes: int):
	lifes_label.text = "Lifes: %d" % lifes

func game_over():
	game_lost_container.show()

func _on_game_lost_btn_pressed() -> void:
	get_tree().reload_current_scene()
