extends Node

signal animation_completed

var animation_scenes := {
	1: "res://lewds/lewdscenes/fleurdelis_ls.tscn",
	2: "res://lewds/lewdscenes/fleurdelis_ls.tscn"
}

func play_level_animation(level: int) -> void:
	if not animation_scenes.has(level):
		print("No animation for level ", level)
		animation_completed.emit()
		return
	
	var scene_path: String = animation_scenes[level]
	print("AnimationManager: Loading ", scene_path)
	
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var scene = get_tree().current_scene
	if not scene:
		animation_completed.emit()
		return
	
	# Wait for animation to complete (simplified)
	await get_tree().create_timer(12.0).timeout
	
	print("AnimationManager: Animation completed")
	animation_completed.emit()

func _on_climax_finished(scene: Node2D):
	print("Climax finished in interactive scene")
	scene.queue_free()
	animation_completed.emit()

func _wait_for_climax(scene: Node2D):
	# Poll for completion (less ideal but works)
	while scene.is_inside_tree():
		# Check if climax has played by accessing the variable
		if scene.has_method("get_climax_played") and scene.get_climax_played():
			break
		await get_tree().process_frame
	
	scene.queue_free()
	animation_completed.emit()
