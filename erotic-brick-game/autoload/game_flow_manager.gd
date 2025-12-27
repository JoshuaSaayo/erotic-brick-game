extends Node

@onready var transition: TransitionManager = get_node("/root/TransitionManager")

func start_game():
	print("GameFlowManager: Starting game")
	GameState.current_level = 1
	GameState.change_phase(GameState.Phase.MAIN_MENU)
	
	# Use transition_to_scene instead of separate fade_in + load_level
	await transition.transition_to_scene("res://main_scenes/game.tscn", 0.8, 0.8)
	
	print("GameFlowManager: Game scene loaded, starting level flow")
	await start_level_flow()

func load_level():
	print("GameFlowManager: Loading level ", GameState.current_level)
	
	# Use transition_to_scene for level transitions too
	await transition.transition_to_scene("res://main_scenes/game.tscn", 0.8, 0.8)
	
	print("GameFlowManager: Game scene loaded, starting level flow")
	await start_level_flow()

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
	
	# REMOVED: Fade to gameplay (after intro dialogue)
	# await transition.fade_in(0.5)
	# await get_tree().process_frame
	
	# 2. Gameplay - Immediate transition without fade
	GameState.change_phase(GameState.Phase.GAMEPLAY)
	GameState.is_dialogue_active = false
	print("GameFlowManager: Gameplay phase started")
	
	# REMOVED: Fade out (after intro dialogue)
	# await transition.fade_out(0.5)

func end_level():
	print("GameFlowManager: Ending level ", GameState.current_level)
	
	# REMOVED: Fade before outro dialogue
	# await transition.fade_in(0.5)
	# await get_tree().process_frame
	
	# 3. Post-dialogue - Immediate transition without fade
	GameState.change_phase(GameState.Phase.POST_DIALOGUE)
	GameState.is_dialogue_active = true
	print("GameFlowManager: Post-dialogue phase")
	
	DialogueManager.start_outro(GameState.current_level)
	await DialogueManager.dialogue_finished
	print("GameFlowManager: Outro dialogue finished")
	
	# Fade after outro dialogue (KEEP THIS ONE for transition to animation)
	
	# 4. Animation/Cutscene
	GameState.change_phase(GameState.Phase.CUTSCENE)
	print("GameFlowManager: Playing interactive animation")
	
	# Get animation path and transition to it
	var animation_path = GameData.get_animation_scene(GameState.current_level)
	if animation_path:
		print("Loading interactive animation: ", animation_path)
		await transition.transition_to_scene(animation_path, 1.0, 1.0)
		
		# Wait for the animation scene to signal completion
		await _wait_for_animation_completion()
		
	else:
		await get_tree().create_timer(2.0).timeout
	
	# 5. Next level or game complete
	if GameState.current_level < 9:
		GameState.current_level += 1
		print("GameFlowManager: Moving to level ", GameState.current_level)
		# Already faded in from animation, just load next level
		get_tree().change_scene_to_file("res://main_scenes/game.tscn")
		await get_tree().process_frame
		await get_tree().process_frame
		# Then fade out to show the new level
		await transition.fade_out(1.0)
		await start_level_flow()

func _wait_for_animation_completion():
	var scene = get_tree().current_scene
	if not scene:
		return await get_tree().create_timer(1.0).timeout
	
	# Check if scene has a completion signal
	if scene.has_signal("animation_completed"):
		await scene.animation_completed
	elif scene.has_signal("climax_finished"):
		await scene.climax_finished
	else:
		# Fallback: wait 15 seconds
		await get_tree().create_timer(15.0).timeout

func game_complete():
	await transition.transition_to_scene("res://main_scenes/main_menu.tscn", 1.0, 1.0)
	print("GameFlowManager: Game complete, going to main menu")
