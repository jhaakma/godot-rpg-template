extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 100
export var ROLL_SPEED = 150
export var FRICTION = 800

var stats = PlayerStats
enum {
	IDLE,
	ROLL,
	ATTACK
}

var state = IDLE
var velocity : Vector2 = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animNode : AnimationPlayer = get_node("AnimationPlayer")
onready var animTree : AnimationTree = get_node("AnimationTree")
onready var animState : AnimationNodeStateMachinePlayback = animTree.get("parameters/playback")
onready var hurtBox = get_node("HurtBox")

func get_input_vector():
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector

func move():
	move_and_slide(velocity)

func _ready():
	stats.connect("no_health", self, "die")
	animTree.active = true

func die():
	print("Dead")
	queue_free()

# State machine
func _physics_process(delta):
	match state:
		IDLE: 
			idle_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

## State functions

# During idle state, take user input to determin action
func idle_state(delta):
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("jump"):
		state = ROLL
		hurtBox.start_invincibility(0.5)
	else:
		var input_vector = get_input_vector()
		if input_vector != Vector2.ZERO:
			roll_vector = input_vector
			animState.travel("Run")
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
			# Set animation direction
			animTree.set("parameters/Idle/blend_position", input_vector)
			animTree.set("parameters/Run/blend_position", input_vector)
			animTree.set("parameters/Attack/blend_position", input_vector)
			animTree.set("parameters/Roll/blend_position", input_vector)
		else:
			animState.travel("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		move()
		
func attack_state(_delta):
	velocity = Vector2.ZERO
	animState.travel("Attack")
	
func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animState.travel("Roll")
	move()

#Animation triggered functions
func attack_anim_finished():
	animState.travel("Idle")
	state = IDLE

func roll_anim_finished():
	velocity = velocity * 0.6
	animState.travel("Idle")
	state = IDLE
	hurtBox.end_invincibility()


func _on_HurtBox_area_entered(_area):
	hurtBox.start_invincibility(0.5)
	hurtBox.create_hit_effect()
	stats.health -= 1
