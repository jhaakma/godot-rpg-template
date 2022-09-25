extends KinematicBody2D

onready var stats = get_node("Stats")

func _ready():
	stats.max_health = 100
	print(stats.health)

const KNOCKBACK_SPEED = 120
var knockback : Vector2 = Vector2.ZERO

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	var direction = ( position - area.owner.position ).normalized()
	knockback = direction * KNOCKBACK_SPEED

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta * KNOCKBACK_SPEED)
	knockback = move_and_slide(knockback)

func _on_Stats_no_health():
	queue_free()
