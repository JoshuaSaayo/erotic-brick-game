extends Node

signal dialogue_line(text: String)
signal dialogue_finished

var dialogues = {}

func _ready():
	load_dialogue_data()

func load_dialogue_data():
	var file = FileAccess.open("res://dialogues/dialogue.json", FileAccess.READ)
	dialogues = JSON.parse_string(file.get_as_text())

func start_intro():
	show_dialogue("intro")

func start_outro():
	show_dialogue("outro")

func show_dialogue(key: String):
	# show text on HUD speech bubble
	emit_signal("dialogue_finished")
