extends Node

@onready var brick_spawner: BrickSpawner = $BrickSpawner
@onready var character_sprite: Node2D = $Arcade/CharacterSprite

func _ready():
	print("Game scene loaded for level ", GameState.current_level)
	
	# Load character sprite based on level
	_load_character()
	
	# Connect to brick spawner's level_completed signal
	if brick_spawner:
		# Make sure the signal exists before connecting
		if brick_spawner.has_signal("level_completed"):
			brick_spawner.level_completed.connect(_on_level_completed)
			print("Connected to brick_spawner.level_completed signal")
		else:
			print("ERROR: brick_spawner doesn't have level_completed signal!")

func _load_character():
	var character_name = _get_character_for_level(GameState.current_level)
	var texture_path = "res://characters/%s.png" % character_name
	
	if ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		character_sprite.texture = texture
		print("Loaded character: ", character_name)
	else:
		print("Warning: Character texture not found: ", texture_path)

func _get_character_for_level(level: int) -> String:
	match level:
		1: return "fleurdelis"
		2: return "rosalyn"
		3: return "dahlia"
		_: return "fleurdelis"

func _on_level_completed():
	print("Game: Level completed, calling FlowManager.end_level()")
	GameFlowManager.end_level()
