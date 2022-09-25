extends Control

var hearts = 1 setget set_hearts
var max_hearts = 1 setget set_max_hearts
const HEART_WIDTH = 15

onready var heartUIEmpty = $HeartUIEmpty
onready var heartUIFull = $HeartUIFull

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	var new_heart_width = HEART_WIDTH * hearts
	if heartUIFull != null:
		heartUIFull.rect_size.x = new_heart_width
	
func set_max_hearts(value):
	print("set max hearts")
	max_hearts = max(value, 1)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = HEART_WIDTH * max_hearts
	
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_hearts")
# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
