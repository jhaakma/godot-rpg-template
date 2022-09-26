extends KinematicBody2D

export var ACCELERATION = 150
export var WALK_SPEED = 30
export var MAX_SPEED = 60
export var ROLL_SPEED = 150
export var FRICTION = 100
export var PUSH_SPEED = 200
export var WANDER_TIME = 3
export var KNOCKBACK_SPEED = 150

const EnemyDeathEffect = preload("res://Scenes/Effects/EnemyDeathEffect.tscn")
const EnemyHitEffect = preload("res://Scenes/Effects/HitEffect.tscn")
onready var stats = get_node("Stats")
onready var sprite = get_node("AnimatedSprite")
onready var detection_zone = get_node("DetectionZone")
onready var world = get_tree().current_scene
onready var hurtBox = get_node("HurtBox")
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer


var knockback : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

#State vars
enum AI_STATE {
	IDLE,
	WANDER
	FOLLOW
	FIGHT
	FLEE
}
var state = AI_STATE.IDLE


func _ready():
	pick_new_state()
	stats.max_health = 100
	sprite.flip_h = randi() % 2 == 1

func _physics_process(delta):
	match state:
		AI_STATE.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_target()
			check_new_state()
		AI_STATE.WANDER:
			var move_vector = global_position.direction_to(wanderController.target_position) * WALK_SPEED 
			velocity = velocity.move_toward(move_vector, ACCELERATION * delta)
			if global_position.distance_to(wanderController.target_position) < 5:
				pick_new_state()
			check_new_state()
			seek_target()
		AI_STATE.FIGHT:
			var target = detection_zone.target
			if target != null:
				var move_vector = global_position.direction_to(target.global_position) * MAX_SPEED
				velocity = velocity.move_toward(move_vector, ACCELERATION * delta)
			else:
				state = AI_STATE.IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * PUSH_SPEED
	velocity = move_and_slide(velocity)
	#Knockback
	knockback = knockback.move_toward(Vector2.ZERO, delta * KNOCKBACK_SPEED)
	knockback = move_and_slide(knockback)
	#Update Sprite direction
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func pick_new_state():
	if global_position.distance_to(wanderController.start_position) > wanderController.wander_range:
		state = AI_STATE.WANDER
	else:
		state = pick_random_state([AI_STATE.IDLE, AI_STATE.WANDER])
	wanderController.start_wander_timer(rand_range(1, WANDER_TIME))
	
func check_new_state():
	if wanderController.get_time_left() == 0:
		pick_new_state()
		
func seek_target():
	if detection_zone.can_see_target():
		state = AI_STATE.FIGHT

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func create_death_effect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position

# Bat gets hit, take damage and get knocked back
func _on_HurtBox_area_entered(area):
	var direction = area.owner.global_position.direction_to(global_position)
	knockback = direction * KNOCKBACK_SPEED
	stats.health -= area.owner.stats.weapon_damage
	hurtBox.start_invincibility(0.4)
	hurtBox.create_hit_effect()
	animationPlayer.play("Start")

func _on_Stats_no_health():
	queue_free()
	create_death_effect()


func _on_HurtBox_invinsible_end():
	animationPlayer.play("Stop")
