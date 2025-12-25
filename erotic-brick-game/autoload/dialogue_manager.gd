extends Node

signal dialogue_started
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
		var content = file.get_as_text()
		dialogues = JSON.parse_string(content)
	else:
		push_error("Failed to load dialogue file")

func start_intro(level: int):
	var level_key = str(level)
	if dialogues.has("levels") and dialogues["levels"].has(level_key):
		var level_data = dialogues["levels"][level_key]
		current_character = level_data["character"]
		current_dialogue_lines = level_data["intro"]
		current_line_index = 0
		emit_signal("dialogue_started")
		show_next_line()

func start_outro(level: int):
	var level_key = str(level)
	if dialogues.has("levels") and dialogues["levels"].has(level_key):
		var level_data = dialogues["levels"][level_key]
		current_character = level_data["character"]
		current_dialogue_lines = level_data["outro"]
		current_line_index = 0
		emit_signal("dialogue_started")
		show_next_line()

func show_next_line():
	if current_line_index < current_dialogue_lines.size():
		var line = current_dialogue_lines[current_line_index]
		emit_signal("dialogue_line", line, current_character)
		current_line_index += 1
	else:
		# All lines shown
		current_dialogue_lines = []
		current_line_index = 0
		emit_signal("dialogue_finished")

func _input(event):
	if event.is_action_pressed("ui_accept") and GameState.is_dialogue_active:
		show_next_line()
