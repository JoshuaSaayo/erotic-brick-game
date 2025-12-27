extends CanvasLayer

signal fade_in_completed
signal fade_out_completed

var _is_fading := false

func _ready():
	layer = 128
	print("TransitionManager loaded (white transitions)")

func fade_in(duration: float = 0.5) -> void:
	if _is_fading:
		return
	
	_is_fading = true
	
	# Create white ColorRect
	var color_rect = ColorRect.new()
	add_child(color_rect)
	
	# Set anchors to fill screen
	color_rect.anchor_left = 0
	color_rect.anchor_top = 0
	color_rect.anchor_right = 1
	color_rect.anchor_bottom = 1
	color_rect.color = Color(1, 1, 1, 0)  # WHITE with 0 alpha
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	tween.tween_callback(color_rect.queue_free)  # Clean up after fade
	
	await tween.finished
	_is_fading = false
	emit_signal("fade_in_completed")

func fade_out(duration: float = 0.5) -> void:
	if _is_fading:
		return
	
	_is_fading = true
	
	# Create white ColorRect
	var color_rect = ColorRect.new()
	add_child(color_rect)
	
	# Set anchors to fill screen
	color_rect.anchor_left = 0
	color_rect.anchor_top = 0
	color_rect.anchor_right = 1
	color_rect.anchor_bottom = 1
	color_rect.color = Color(1, 1, 1, 1)  # WHITE with full alpha
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	tween.tween_callback(color_rect.queue_free)  # Clean up after fade
	
	await tween.finished
	_is_fading = false
	emit_signal("fade_out_completed")

func transition_to_scene(scene_path: String, fade_in_duration: float = 0.5, fade_out_duration: float = 0.5) -> void:
	await fade_in(fade_in_duration)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	await fade_out(fade_out_duration)
