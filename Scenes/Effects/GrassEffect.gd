extends Node2D

onready var sprite : AnimatedSprite = get_node("AnimatedSprite")

func _ready():
	sprite.frame = 0
	sprite.play("Animate")
	
func _on_AnimatedSprite_animation_finished():
	queue_free()
