extends Node

func start_game():
	print("FlowManager: Starting game...")
	GameState.current_level = 1
	GameState.change_phase(GameState.Phase.MAIN_MENU)
	load_level()

func load_level():
	print("FlowManager: Loading level ", GameState.current_level)
	
	# Load game scene
	get_tree().change_scene_to_file("res://main_scenes/game.tscn")
	
	# Wait for scene to load
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("FlowManager: Scene loaded, starting level flow")
	start_level_flow()

func start_level_flow():
	print("FlowManager: Starting level flow for level ", GameState.current_level)
	
	# Wait a bit to ensure everything is loaded
	await get_tree().create_timer(0.3).timeout
	
	# 1. Pre-dialogue
	GameState.change_phase(GameState.Phase.PRE_DIALOGUE)
	GameState.is_dialogue_active = true
	print("FlowManager: Pre-dialogue phase")
	
	# Start intro dialogue
	DialogueManager.start_intro(GameState.current_level)
	
	# Wait for dialogue to complete
	await DialogueManager.dialogue_finished
	print("FlowManager: Dialogue finished, moving to gameplay")
	
	# 2. Gameplay
	GameState.change_phase(GameState.Phase.GAMEPLAY)
	GameState.is_dialogue_active = false
	print("FlowManager: Gameplay phase - enabling gameplay")
	
	# Enable gameplay
	enable_gameplay()

func enable_gameplay():
	print("FlowManager: Enabling gameplay")
	# Call enable on all gameplay nodes
	get_tree().call_group("gameplay", "enable_gameplay")

func disable_gameplay():
	print("FlowManager: Disabling gameplay")
	get_tree().call_group("gameplay", "disable_gameplay")

func end_level():
	print("FlowManager: Ending level ", GameState.current_level)
	
	# Disable gameplay first
	disable_gameplay()
	
	# 3. Post-dialogue
	GameState.change_phase(GameState.Phase.POST_DIALOGUE)
	GameState.is_dialogue_active = true
	print("FlowManager: Post-dialogue phase")
	
	# Start outro dialogue
	DialogueManager.start_outro(GameState.current_level)
	
	# Wait for dialogue to complete
	await DialogueManager.dialogue_finished
	print("FlowManager: Outro dialogue finished")
	
	# 4. Cutscene/Animation
	GameState.change_phase(GameState.Phase.CUTSCENE)
	print("FlowManager: Playing animation")
	
	# Play animation for current level
	if AnimationManager:
		AnimationManager.play_level_animation(GameState.current_level)
		await AnimationManager.animation_completed
	else:
		print("WARNING: AnimationManager not found, skipping animation")
		await get_tree().create_timer(1.0).timeout  # Fake delay
	
	# 5. Next level or game complete
	if GameState.current_level < 9:
		print("FlowManager: Moving to next level")
		GameState.current_level += 1
		load_level()
	else:
		print("FlowManager: Game complete!")
		game_complete()

func game_complete():
	print("FlowManager: Game complete, returning to main menu")
	# Return to main menu or show credits
	get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")
