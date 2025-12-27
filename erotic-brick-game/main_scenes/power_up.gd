extends Area2D
class_name PowerUp

enum Type { EXPAND_PADDLE, MULTI_BALL }

@export var type: Type
@export var fall_speed := 200.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Set sprite based on type
	match type:
		Type.EXPAND_PADDLE:
			sprite.texture = preload("res://assets/game_assets/ups_1.png")
		Type.MULTI_BALL:
			sprite.texture = preload("res://assets/game_assets/ups_2.png")
	
	print("PowerUp created, type: ", type, " at position: ", global_position)

func _physics_process(delta):
	# Move downward
	position.y += fall_speed * delta
	
	# Remove if it goes off screen
	if global_position.y > get_viewport_rect().size.y + 50:
		print("PowerUp fell off screen, removing")
		queue_free()

func _on_body_entered(body):
	print("PowerUp hit: ", body.name)
	
	if body is Paddle:
		print("Applying powerup effect to paddle")
		apply_effect(body)
		queue_free()

func apply_effect(paddle: Paddle):
	match type:
		Type.EXPAND_PADDLE:
			print("Applying EXPAND_PADDLE effect")
			if paddle.has_method("expand"):
				paddle.expand()
			else:
				print("ERROR: Paddle doesn't have expand() method")
		
		Type.MULTI_BALL:
			print("Applying MULTI_BALL effect")
			if paddle.has_method("spawn_multiball"):
				paddle.spawn_multiball()
			else:
				print("ERROR: Paddle doesn't have spawn_multiball() method")
