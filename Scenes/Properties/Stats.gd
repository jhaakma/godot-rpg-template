extends Node

export var weapon_damage = 1
export(int, 0, 2147483647) var max_health = 1

signal no_health

onready var health = max_health setget set_health
func set_health(new_health):
	health = new_health
	if health <= 0:
		emit_signal("no_health")


