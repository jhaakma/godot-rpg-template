extends Node

export var weapon_damage = 1
export(int, 1, 2147483647) var max_health setget set_max_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

onready var health = max_health setget set_health

func set_max_health(value):
	max_health = max(1, value)
	emit_signal("max_health_changed", max_health)
	if health != null and health > max_health:
		self.set_health(max_health)

func set_health(new_health):
	health = new_health
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
