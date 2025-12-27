extends RigidBody2D

class_name Brick

signal brick_destroyed(brick: Brick)  # Specify parameter type

var level = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var sprites: Array[Texture2D] = [
	preload("res://assets/game_assets/brick_1.png"),
	preload("res://assets/game_assets/brick_2.png"),
	preload("res://assets/game_assets/brick_3.png"),
	preload("res://assets/game_assets/brick_4.png"),
	preload("res://assets/game_assets/brick_5.png"),
]

func get_size():
	return collision_shape_2d.shape.get_rect().size * sprite_2d.scale
	
func set_level(new_level: int):
	level = new_level
	sprite_2d.texture = sprites[new_level - 1]
	
func decrease_level():
	if level > 1:
		set_level(level - 1)
	else:
		fade_out()
		
func fade_out():
	collision_shape_2d.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.TRANSPARENT, .5)
	tween.tween_callback(destroy)
	
func destroy():
	brick_destroyed.emit(self)  # EMIT ONLY HERE
	queue_free()

func get_width():
	return get_size().x
