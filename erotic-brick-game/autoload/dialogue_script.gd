extends Node
class_name DialogueManager

signal dialogue_finished

var dialogues: Dictionary
var current_lines: Array[String]
var index := 0

func _ready():
	var file = FileAccess.open("res://data/dialogue.json", FileAccess.READ)
	dialogues = JSON.parse_string(file.get_as_text())

func play_dialogue(level_id: int, phase: String):
	index = 0
	current_lines = dialogues["levels"][str(level_id)][phase]
	show_next()

func show_next():
	if index >= current_lines.size():
		dialogue_finished.emit()
		return

	$DialogueBubble.set_text(current_lines[index])
	index += 1
