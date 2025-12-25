extends Node

enum Phase {
	MAIN_MENU,
	PRE_DIALOGUE,
	GAMEPLAY,
	POST_DIALOGUE,
	CUTSCENE,
	LEVEL_COMPLETE
}

var current_phase: Phase = Phase.MAIN_MENU
var current_level: int = 1
var is_dialogue_active: bool = false

signal phase_changed(new_phase: Phase)
signal level_changed(new_level: int)

# Helper function to change phase
func change_phase(new_phase: Phase):
	if current_phase != new_phase:
		current_phase = new_phase
		phase_changed.emit(new_phase)
		print("GameState: Phase changed to ", new_phase)
