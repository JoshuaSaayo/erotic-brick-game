extends Node

@onready var brick_spawner: BrickSpawner = $BrickSpawner
@onready var character_container: Node2D = $Arcade/CharacterSprite

var current_character_scene: Node = null
var character_anim: AnimationPlayer = null  # NEW: Store reference to animation player

func _ready():
	print("Game scene loaded for level ", GameState.current_level)
	_load_character()
	
	if brick_spawner:
		brick_spawner.level_completed.connect(_on_level_completed)
		brick_spawner.bricks_destroyed.connect(_on_bricks_destroyed)  # NEW: Connect progress signal

func _load_character():
	var scene_path = GameData.get_character_scene(GameState.current_level)
	var character_name = GameData.get_character(GameState.current_level)
	
	print("Loading character: ", character_name)
	
	# Remove previous character scene
	if current_character_scene:
		current_character_scene.queue_free()
		current_character_scene = null
	
	# Load new character scene
	if ResourceLoader.exists(scene_path):
		var character_scene = load(scene_path).instantiate()
		character_container.add_child(character_scene)
		current_character_scene = character_scene
		
		# Add to character group for global access
		character_scene.add_to_group("character")
		
		# Position and scale
		character_scene.position = Vector2(300, 400)
		character_scene.scale = Vector2(1.5, 1.5)
		
		# Store reference to animation player
		character_anim = character_scene.get_node_or_null("anim")
		if character_anim:
			# Play initial pose
			if character_anim.has_animation("pose_1"):
				character_anim.play("pose_1")
			elif character_anim.get_animation_list().size() > 0:
				for anim_name in character_anim.get_animation_list():
					if anim_name != "RESET":
						character_anim.play(anim_name)
						break
		
		print("Character loaded")
	else:
		print("ERROR: Character scene not found: ", scene_path)

# NEW: Handle brick destruction progress
func _on_bricks_destroyed(destroyed: int, total: int):
	var percentage = float(destroyed) / total * 100
	print("Brick progress: ", destroyed, "/", total, " (", percentage, "%)")
	
	# React at 50% and 75%
	if percentage >= 50 and percentage < 75:
		_on_half_bricks_destroyed()
	elif percentage >= 75:
		_on_most_bricks_destroyed()

# NEW: Character reaction to half bricks destroyed
func _on_half_bricks_destroyed():
	print("Character reacting to half bricks destroyed!")
	
	if character_anim:
		if character_anim.has_animation("pose_2"):
			character_anim.play("pose_2")
			print("Playing pose_2 animation")
		elif character_anim.has_animation("excited"):
			character_anim.play("excited")
		else:
			# Fallback: scale up briefly
			var original_scale = current_character_scene.scale
			var tween = create_tween()
			tween.tween_property(current_character_scene, "scale", original_scale * 1.2, 0.3)
			tween.tween_property(current_character_scene, "scale", original_scale, 0.3)

# NEW: Character reaction to most bricks destroyed
func _on_most_bricks_destroyed():
	print("Character excited - most bricks destroyed!")
	
	if character_anim:
		if character_anim.has_animation("excited"):
			character_anim.play("excited")
		elif character_anim.has_animation("pose_2"):
			# Play pose_2 with faster speed
			character_anim.play("pose_2")
			character_anim.speed_scale = 1.5
		else:
			# Visual feedback: pulse effect
			var tween = create_tween()
			tween.tween_property(current_character_scene, "modulate", Color(1, 1, 0.8, 1), 0.2)
			tween.tween_property(current_character_scene, "modulate", Color.WHITE, 0.2)

func _on_level_completed():
	print("Level completed!")
	GameFlowManager.end_level()
