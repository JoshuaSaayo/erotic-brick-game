extends Node

@onready var brick_spawner: BrickSpawner = $BrickSpawner
@onready var character_container: Node2D = $Arcade/CharacterSprite

var current_character_scene: Node = null

func _ready():
	print("Game scene loaded for level ", GameState.current_level)
	_load_character()
	
	if brick_spawner:
		brick_spawner.level_completed.connect(_on_level_completed)

func _load_character():
	var character_name = GameData.get_character(GameState.current_level)
	var scene_path = "res://lewds/lewdscenes/%s_ls.tscn" % character_name
	
	# Remove previous character
	if current_character_scene:
		current_character_scene.queue_free()
	
	# Load new character
	if ResourceLoader.exists(scene_path):
		var character_scene = load(scene_path).instantiate()
		character_container.add_child(character_scene)
		current_character_scene = character_scene
		print("Loaded character: ", character_name)
		
		# Play idle animation if available
		var anim = character_scene.get_node_or_null("Node2D/anim")
		if anim and anim.has_animation("idle"):
			anim.play("idle")
	else:
		print("Warning: Character scene not found: ", scene_path)

func _on_level_completed():
	print("Level completed, starting outro flow")
	GameFlowManager.end_level()
