extends Node2D

onready var world = get_tree().current_scene
onready var player = world.find_node("Player")
const GrassEffect = preload("res://Scenes/Effects/GrassEffect.tscn")

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	world.add_child(grassEffect)
	grassEffect.position = position
		
func _on_HurtBox_area_entered(area):
	create_grass_effect()
	queue_free()
