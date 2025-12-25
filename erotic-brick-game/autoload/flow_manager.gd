extends Node
class_name GameFlowManager

@export var dialogue_manager: DialogueManager
@export var gameplay: Node
@export var cutscene_player: Node
@export var character_panel: Node

var current_level := 1
var state := GameState.MENU

func start_game():
	load_level(current_level)

func load_level(level_id: int):
	state = GameState.PRE_DIALOGUE
	character_panel.show_character(level_id)
	dialogue_manager.play_dialogue(level_id, "intro")

func on_intro_dialogue_finished():
	state = GameState.GAMEPLAY
	gameplay.start_level()

func on_level_complete():
	state = GameState.POST_DIALOGUE
	dialogue_manager.play_dialogue(current_level, "outro")

func on_outro_dialogue_finished():
	state = GameState.CUTSCENE
	cutscene_player.play_cutscene(current_level)

func on_cutscene_finished():
	current_level += 1
	load_level(current_level)
