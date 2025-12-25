extends Node

signal animation_completed

var animation_scenes = {
	1: "res://lewds/lewdscenes/fleurdelis_ls.tscn",
	2: "res://lewds/lewdscenes/fleurdelis_ls.tscn",
	# ... add all 9 levels
}

func play_level_animation(level: int):
	if animation_scenes.has(level):
		# Play LS animation (10 seconds loop)
		var animation_scene_path = animation_scenes[level]
		get_tree().change_scene_to_file(animation_scene_path)
		
		# Wait for scene to load and get animation player
		await get_tree().process_frame
		
		var current_scene = get_tree().current_scene
		var animation_player = current_scene.get_node("anim")
		
		# Play LS animation
		animation_player.play("lewdscene")
		await get_tree().create_timer(10.0).timeout
		
		# Play climax animation
		animation_player.play("climax")
		await animation_player.animation_finished
		
		# Animation completed
		emit_signal("animation_completed")
