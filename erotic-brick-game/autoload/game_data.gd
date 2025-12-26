extends Node

var level_data: Dictionary = {}

func _ready():
	load_game_data()

func load_game_data():
	var file = FileAccess.open("res://dialogues/dialogue.json", FileAccess.READ)
	if file:
		level_data = JSON.parse_string(file.get_as_text())
		print("Loaded data for ", level_data["levels"].size(), " levels")
	else:
		push_error("Failed to load game_data.json")

func get_level_data(level: int) -> Dictionary:
	var level_key = str(level)
	return level_data.get("levels", {}).get(level_key, {})

func get_brick_layout(level: int) -> Array:
	return get_level_data(level).get("bricks", [])

func get_character(level: int) -> String:
	return get_level_data(level).get("character", "fleurdelis")

func get_character_scene(level: int) -> String:
	return get_level_data(level).get("character_scene", "res://characters/fleurdelis_level.tscn")

func get_animation_scene(level: int) -> String:
	return get_level_data(level).get("animation", "")
