extends Node

func start_game():
	GameState.phase = GameState.GamePhase.DIALOGUE
	Dialogues.start_intro()

func start_gameplay():
	GameState.phase = GameState.GamePhase.GAMEPLAY
	get_tree().call_group("gameplay", "enable_gameplay")

func end_level():
	GameState.phase = GameState.GamePhase.DIALOGUE
	Dialogues.start_outro()

func next_level():
	GameState.current_level += 1
	load_level()

func talk():
	$AnimationPlayer.play("talk")

func idle():
	$AnimationPlayer.play("idle")

func load_level():
	get_tree().change_scene_to_file("res://main_scenes/game.tscn")
