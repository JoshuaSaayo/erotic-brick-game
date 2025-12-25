extends Node

@onready var game_state = get_node("/root/GameState")

func start_game():
	game_state.current_level = 1
	load_level()

func load_level():
	# Load game scene first
	get_tree().change_scene_to_file("res://main_scenes/game.tscn")
	await get_tree().process_frame  # Wait for scene to load
	
	# Start level flow
	start_level_flow()

func start_level_flow():
	# 1. Pre-dialogue
	game_state.current_phase = GameState.Phase.PRE_DIALOGUE
	game_state.is_dialogue_active = true
	DialogueManager.start_intro(game_state.current_level)
	
	# Wait for dialogue to complete
	await DialogueManager.dialogue_finished
	
	# 2. Gameplay
	game_state.current_phase = GameState.Phase.GAMEPLAY
	game_state.is_dialogue_active = false
	get_tree().call_group("gameplay", "enable_gameplay")

func end_level():
	# 3. Post-dialogue
	game_state.current_phase = GameState.Phase.POST_DIALOGUE
	game_state.is_dialogue_active = true
	DialogueManager.start_outro(game_state.current_level)
	
	# Wait for dialogue to complete
	await DialogueManager.dialogue_finished
	
	# 4. Cutscene/Animation
	game_state.current_phase = GameState.Phase.CUTSCENE
	play_animation_for_level(game_state.current_level)
	
	# Wait for animation to complete
	await AnimationManager.animation_completed
	
	# 5. Next level or game complete
	if game_state.current_level < 9:
		game_state.current_level += 1
		load_level()
	else:
		game_complete()

func play_animation_for_level(level: int):
	AnimationManager.play_level_animation(level)

func game_complete():
	# Return to main menu or show credits
	get_tree().change_scene_to_file("res://main_scenes/main_menu.tscn")
