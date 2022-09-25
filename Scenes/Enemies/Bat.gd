extends KinematicBody2D

const EnemyDeathEffect = preload("res://Scenes/Effects/EnemyDeathEffect.tscn")
const EnemyHitEffect = preload("res://Scenes/Effects/HitEffect.tscn")
onready var stats = get_node("Stats")
onready var sprite = get_node("AnimatedSprite")
onready var detection_zone = get_node("DetectionZone")
onready var world = get_tree().current_scene
onready var hurtBox = get_node("HurtBox")
export var ACCELERATION = 200
export var MAX_SPEED = 50
export var ROLL_SPEED = 150
export var FRICTION = 150
const KNOCKBACK_SPEED = 200
var knockback : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

#State vars
enum AI_STATE {
	WANDER,
	WAIT
	FOLLOW
	FIGHT
	FLEE
}
export(AI_STATE) var start_state = AI_STATE.WANDER
var state = start_state

func _ready():
	stats.max_health = 100
	sprite.flip_h = randi() % 2 == 1


func get_vector_to_target(from, to):
	return ( from.position - to.position ).normalized()


func _physics_process(delta):
	match state:
		AI_STATE.WANDER:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_target()
		AI_STATE.WAIT:
			pass
		AI_STATE.FOLLOW:
			pass
		AI_STATE.FIGHT:
			var target = detection_zone.target
			if target != null:
				var move_vector = get_vector_to_target(target, self) * MAX_SPEED
				velocity = velocity.move_toward(move_vector, ACCELERATION * delta)
			else:
				state = AI_STATE.WANDER
		AI_STATE.FLEE:
			pass
			
	velocity = move_and_slide(velocity)
	#Knockback
	knockback = knockback.move_toward(Vector2.ZERO, delta * KNOCKBACK_SPEED)
	knockback = move_and_slide(knockback)
	#Sprite
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
			
func seek_target():
	if detection_zone.can_see_target():
		state = AI_STATE.FIGHT

	
func create_death_effect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position

func _on_HurtBox_area_entered(area):
	var direction = get_vector_to_target(self, area.owner)
	knockback = direction * KNOCKBACK_SPEED
	stats.health -= area.owner.stats.weapon_damage
	hurtBox.start_invincibility(0.5)
	hurtBox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	create_death_effect()
