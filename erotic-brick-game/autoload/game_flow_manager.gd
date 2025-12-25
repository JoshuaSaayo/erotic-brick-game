extends Node

var current_scene: Node = null

func start_game():
	print("FlowManager: Starting game")
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
	
	print("FlowManager: Game scene loaded, starting level flow")
	start_level_flow()

func start_level_flow():
	print("FlowManager: Starting level flow for level ", GameState.current_level)
	
	# Wait a moment for everything to initialize
	await get_tree().create_timer(0.5).timeout
	
	# 1. Pre-dialogue
	GameState.change_phase(GameState.Phase.PRE_DIALOGUE)
	GameState.is_dialogue_active = true
	print("FlowManager: Pre-dialogue phase")
	
	DialogueManager.start_intro(GameState.current_level)
	await DialogueManager.dialogue_finished
	print("FlowManager: Intro dialogue finished")
	
	# 2. Gameplay
	GameState.change_phase(GameState.Phase.GAMEPLAY)
	GameState.is_dialogue_active = false
	print("FlowManager: Gameplay phase started")

func end_level():
	print("FlowManager: Ending level ", GameState.current_level)
	
	# 3. Post-dialogue
	GameState.change_phase(GameState.Phase.POST_DIALOGUE)
	GameState.is_dialogue_active = true
	print("FlowManager: Post-dialogue phase")
	
	DialogueManager.start_outro(GameState.current_level)
	await DialogueManager.dialogue_finished
	print("FlowManager: Outro dialogue finished")
	
	# 4. Animation/Cutscene
	GameState.change_phase(GameState.Phase.CUTSCENE)
	print("FlowManager: Playing animation")
	
	AnimationManager.play_level_animation(GameState.current_level)
	await AnimationManager.animation_completed
	print("FlowManager: Animation completed")
	
	# 5. Next level or game complete
	if GameState.current_level < 9:  # Change 9 to your max level
		GameState.current_level += 1
		print("FlowManager: Moving to level ", GameState.current_level)
		load_level()
	else:
		print("FlowManager: Game complete!")
		game_complete()

func game_complete():
	print("FlowManager: Game complete, going to main menu")
	get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")
