extends Control


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scenes/game.tscn")
