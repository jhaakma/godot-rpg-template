extends Node2D

onready var world = get_tree().current_scene
onready var player = world.find_node("Player")

func create_grass_effect():
		#if player.get_within_attack_range(self):
		var GrassEffect = load("res://Scenes/Effects/GrassEffect.tscn")
		var grassEffect = GrassEffect.instance()
		world.find_node("Grass").add_child(grassEffect)
		grassEffect.position = position
		
func _on_HurtBox_area_entered(area):
	create_grass_effect()
	queue_free()
