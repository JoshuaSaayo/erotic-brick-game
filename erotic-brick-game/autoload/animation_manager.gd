extends Node

signal animation_completed

var animation_scenes := {
	1: "res://lewds/lewdscenes/fleurdelis_ls.tscn",
	2: "res://lewds/lewdscenes/fleurdelis_ls.tscn"
}

func play_level_animation(level: int) -> void:
	if not animation_scenes.has(level):
		# Skip animation if not found
		print("No animation for level ", level)
		animation_completed.emit()
		return
	
	var scene_path: String = animation_scenes[level]
	print("Loading animation: ", scene_path)
	
	# Load the animation scene
	get_tree().change_scene_to_file(scene_path)
	
	# Wait for scene to load
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Get the current scene
	var scene = get_tree().current_scene
	if not scene:
		print("Failed to load animation scene")
		animation_completed.emit()
		return
	
	print("Animation scene loaded: ", scene.name)
	
	# Wait for animation to complete
	# We'll use a simple timer-based approach for now
	await get_tree().create_timer(12.0).timeout  # Wait 12 seconds total
	
	print("Animation time finished, moving to next level")
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
