extends Node

export(int, 0, 2147483647) var max_health = 1
onready var health = max_health setget set_health

export var weapon_damage = 1

func set_health(new_health):
	health = new_health
	if health <= 0:
		emit_signal("no_health")

signal no_health
