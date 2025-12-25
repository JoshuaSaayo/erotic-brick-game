extends Node

signal animation_completed

var current_animation_scene: Node = null

func play_level_animation(level: int):
	var animation_path = GameData.get_animation_scene(level)
	
	if animation_path.is_empty():
		print("No animation for level ", level)
		animation_completed.emit()
		return
	
	print("Loading animation: ", animation_path)
	get_tree().change_scene_to_file(animation_path)
	
	# Wait for scene to load
	await get_tree().process_frame
	await get_tree().process_frame
	
	var scene = get_tree().current_scene
	if not scene:
		animation_completed.emit()
		return
	
	# Wait for animation to complete
	await get_tree().create_timer(12.0).timeout
	
	animation_completed.emit()

func _play_animation_sequence():
	# Find AnimationPlayer
	var anim = current_animation_scene.get_node_or_null("Node2D/anim")
	if not anim:
		animation_completed.emit()
		return
	
	# Play lewdscene for 10 seconds
	anim.play("lewdscene")
	await get_tree().create_timer(10.0).timeout
	
	# Play climax
	if anim.has_animation("climax"):
		anim.stop()
		anim.play("climax")
		await anim.animation_finished
	
	# Clean up
	current_animation_scene.queue_free()
	current_animation_scene = null
	
