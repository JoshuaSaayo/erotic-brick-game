extends CanvasLayer
class_name HUD

@export var lifes_label: Label
@export var next_button: Button
@export var speech_bubble: Panel
@export var speech: Label
@export var character_name: Label
@export var game_lost_container: CenterContainer

func _ready():
	speech_bubble.hide()
	next_button.hide()
	
	DialogueManager.dialogue_line.connect(_on_dialogue_line)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	GameState.phase_changed.connect(_on_phase_changed)
	
	next_button.pressed.connect(_on_next_button_pressed)

func set_lifes(lifes: int):
	lifes_label.text = "Lifes: %d" % lifes

func _on_dialogue_line(text: String, character: String):
	character_name.text = character
	speech.text = text
	speech_bubble.show()
	next_button.show()

func _on_dialogue_finished():
	speech_bubble.hide()
	next_button.hide()

func _on_next_button_pressed():
	DialogueManager.show_next_line()

func _on_phase_changed(new_phase: GameState.Phase):
	if new_phase == GameState.Phase.GAMEPLAY:
		speech_bubble.hide()
		next_button.hide()

func game_over():
	game_lost_container.show()

func _on_game_lost_btn_pressed():
	get_tree().reload_current_scene()
