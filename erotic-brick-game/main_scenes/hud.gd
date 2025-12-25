extends CanvasLayer

class_name HUD

@export var lifes_label: Label
@onready var game_lost_container: CenterContainer = $GameLostContainer

func set_lifes(lifes: int):
	lifes_label.text = "Lifes: %d" % lifes

func game_over():
	game_lost_container.show()

func _on_game_lost_btn_pressed() -> void:
	get_tree().reload_current_scene()
