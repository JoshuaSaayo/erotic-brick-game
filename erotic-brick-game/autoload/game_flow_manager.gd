extends Node

func start_game():
	print("GameFlowManager: Starting game")
	GameState.current_level = 1
	GameState.change_phase(GameState.Phase.MAIN_MENU)
	load_level()

func load_level():
	print("GameFlowManager: Loading level ", GameState.current_level)
	
	# Load game scene
	get_tree().change_scene_to_file("res://main_scenes/game.tscn")
	
	# Wait for scene to load
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("GameFlowManager: Game scene loaded, starting level flow")
	start_level_flow()

func start_level_flow():
	print("GameFlowManager: Starting level flow for level ", GameState.current_level)
	
	# Wait a moment for everything to initialize
	await get_tree().create_timer(0.5).timeout
	
	# 1. Pre-dialogue
	GameState.change_phase(GameState.Phase.PRE_DIALOGUE)
	GameState.is_dialogue_active = true
	print("GameFlowManager: Pre-dialogue phase")
	
	DialogueManager.start_intro(GameState.current_level)
	await DialogueManager.dialogue_finished
	print("GameFlowManager: Intro dialogue finished")
	
	# 2. Gameplay
	GameState.change_phase(GameState.Phase.GAMEPLAY)
	GameState.is_dialogue_active = false
	print("GameFlowManager: Gameplay phase started")

func end_level():
	print("GameFlowManager: Ending level ", GameState.current_level)
	
	# 3. Post-dialogue
	GameState.change_phase(GameState.Phase.POST_DIALOGUE)
	GameState.is_dialogue_active = true
	print("GameFlowManager: Post-dialogue phase")
	
	DialogueManager.start_outro(GameState.current_level)
	await DialogueManager.dialogue_finished
	print("GameFlowManager: Outro dialogue finished")
	
	# 4. Animation/Cutscene
	GameState.change_phase(GameState.Phase.CUTSCENE)
	print("GameFlowManager: Playing interactive animation")
	
	var animation_path = GameData.get_animation_scene(GameState.current_level)
	if animation_path:
		print("Loading interactive animation: ", animation_path)
		get_tree().change_scene_to_file(animation_path)
		
		# Wait for the animation scene to signal completion
		# The animation scene should emit a signal when climax is done
		await _wait_for_animation_completion()
	else:
		await get_tree().create_timer(2.0).timeout
	
	# 5. Next level or game complete
	if GameState.current_level < 9:  # Change 9 to your max level
		GameState.current_level += 1
		print("GameFlowManager: Moving to level ", GameState.current_level)
		load_level()
	else:
		print("GameFlowManager: Game complete!")
		game_complete()

func _wait_for_animation_completion():
	# Wait for scene to load
	await get_tree().process_frame
	await get_tree().process_frame
	
	var scene = get_tree().current_scene
	if not scene:
		return
	
	# Check if scene has a completion signal
	if scene.has_signal("animation_completed"):
		await scene.animation_completed
	elif scene.has_signal("climax_finished"):
		await scene.climax_finished
	else:
		# Fallback: wait 15 seconds
		await get_tree().create_timer(15.0).timeout

# ADD THIS FUNCTION
func game_complete():
	print("GameFlowManager: Game complete, going to main menu")
	get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")
