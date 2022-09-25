extends Area2D

const EnemyHitEffect = preload("res://Scenes/Effects/HitEffect.tscn")

var invincible = false

onready var timer = get_node("Timer")

signal invinsible_start
signal invinsible_end

func start_invincibility(duration):
	emit_signal("invinsible_start")
	self.invincible = true
	timer.start(duration)

func end_invincibility():
	emit_signal("invinsible_end")
	self.invincible = false

func _on_Timer_timeout():
	end_invincibility()

func create_hit_effect():
	var effect = EnemyHitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(effect)
	effect.global_position = global_position

func _on_HurtBox_invinsible_end():
	set_deferred ("monitoring", true)

func _on_HurtBox_invinsible_start():
	set_deferred ("monitoring", false)
