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
	# Get character scene path from GameData
	var scene_path = GameData.get_character_scene(GameState.current_level)
	var character_name = GameData.get_character(GameState.current_level)
	
	print("=== DEBUG CHARACTER LOADING ===")
	print("Current level: ", GameState.current_level)
	print("Character name: ", character_name)
	print("Scene path from GameData: ", scene_path)
	
	# Check if path exists
	var path_exists = ResourceLoader.exists(scene_path)
	print("Path exists? ", path_exists)
	
	# Remove previous character scene
	if current_character_scene:
		print("Removing previous character scene")
		current_character_scene.queue_free()
		current_character_scene = null
	
	# Load new character scene
	if path_exists:
		print("Attempting to load scene...")
		var character_scene = load(scene_path)
		print("Scene loaded: ", character_scene)
		
		if character_scene:
			var instance = character_scene.instantiate()
			print("Scene instantiated: ", instance)
			
			character_container.add_child(instance)
			current_character_scene = instance
			print("Added to character_container")
			print("Character_container children: ", character_container.get_children())
			
			# Make sure it's visible and positioned correctly
			instance.position = Vector2.ZERO
			print("Set position to: ", instance.position)
			
			# Play idle animation if available
			var anim = instance.get_node_or_null("anim")
			if anim:
				print("Found AnimationPlayer, available animations: ", anim.get_animation_list())
				
				# Play first available animation (skip "RESET" if it's just a reset)
				for anim_name in anim.get_animation_list():
					if anim_name != "RESET" and anim_name != "reset":
						anim.play(anim_name)
						print("Playing animation: ", anim_name)
						break

func _try_alternative_paths(character_name: String):
	# Try common alternative paths
	var possible_paths = [
		"res://characters/%s_level.tscn" % character_name,
		"res://characters/%s.tscn" % character_name,
		"res://main_scenes/characters/%s_level.tscn" % character_name
	]
	
	for path in possible_paths:
		if ResourceLoader.exists(path):
			print("Found at alternative path: ", path)
			# You could load from here instead
			return
	
	print("No character scene found at any path")

func _on_level_completed():
	print("Level completed, starting outro flow")
	GameFlowManager.end_level()
