extends Node

signal dialogue_line(text: String, character: String)
signal dialogue_finished

var dialogues = {}
var current_dialogue_lines: Array = []
var current_line_index: int = 0
var current_character: String = ""

func _ready():
	load_dialogue_data()

func load_dialogue_data():
	var file = FileAccess.open("res://dialogues/dialogue.json", FileAccess.READ)
	if file:
		dialogues = JSON.parse_string(file.get_as_text())
	else:
		push_error("Failed to load dialogue file")

func start_dialogue(level: int, type: String):
	var level_key = str(level)
	if dialogues.get("levels", {}).has(level_key):
		var level_data = dialogues["levels"][level_key]
		current_character = level_data["character"]
		current_dialogue_lines = level_data[type]
		current_line_index = 0
		show_next_line()
	else:
		dialogue_finished.emit()

func start_intro(level: int):
	start_dialogue(level, "intro")

func start_outro(level: int):
	start_dialogue(level, "outro")

func show_next_line():
	if current_line_index < current_dialogue_lines.size():
		var line = current_dialogue_lines[current_line_index]
		dialogue_line.emit(line, current_character)
		current_line_index += 1
	else:
		end_dialogue()

func end_dialogue():
	current_dialogue_lines = []
	current_line_index = 0
	dialogue_finished.emit()

func _input(event):
	if event.is_action_pressed("ui_accept") and GameState.is_dialogue_active:
		show_next_line()
