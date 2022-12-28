extends KinematicBody2D

# debug
var vec_dif = 0

# movement characteristics
export var ACCELERATION = 600
export var MAX_SPEED = 80
export var FRICTION = 0.6
export var PIXEL_PERF = true

var velocity = Vector2.ZERO
var deadzone = 0.2

# states
var player_state = 'idle'
var player_action = 'none'
var input_vector = Vector2.ZERO
var look_vector = Vector2.ZERO

# useful
var look_angle
var arm_angle

# aiming body look
var aim_dir = 0
var move_dir = 0
var torso_dir = 0

# body part animators
onready var head_player = $Animators/HeadPlayer
onready var torso_player = $Animators/TorsoPlayer
onready var legs_player = $Animators/LegsPlayer
onready var frontarm_player = $Animators/FrontArmPlayer
onready var backarm_player = $Animators/BackArmPlayer

# arm rotators
onready var frontarm_body = $FrontArm/FrontArmSprite
onready var backarm_body = $BackArm/BackArmSprite


# convert radians to look angle 0-7, clockwise from east=0
func eight_way(dir_angle):
	var ret = stepify(dir_angle, PI/4) / (PI/4)
	return wrapi(int(ret), 0, 8)

func move_player(delta):
	# get movement input L stick
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if PIXEL_PERF:
		if input_vector.x > 0:
			input_vector.x = 1
		elif input_vector.x < 0:
			input_vector.x = -1
		if input_vector.y > 0:
			input_vector.y = 0.5
		elif input_vector.y < 0:
			input_vector.y= -0.5
	
	# calculate velocity, set move vas idle state
	if input_vector != Vector2.ZERO:
		velocity += input_vector * ACCELERATION * delta
		velocity = velocity.limit_length(MAX_SPEED)
		player_state = 'move'
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION)
		player_state = 'idle'
	
	# builtin movement func
	velocity = move_and_slide(velocity)

func aim_player():
	# get aim input R stick
	look_vector.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	look_vector.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	look_vector = look_vector.normalized()
	
	# need this a bunch for rotating arms, might as well store
	look_angle = look_vector.angle()
	
	# only calculate or change move dir if there is input
	if input_vector:
		move_dir = eight_way(input_vector.angle())
	
	# likewise for aiming, else set to last move dir
	if look_vector:
		aim_dir = eight_way(look_angle)
	else:
		aim_dir = move_dir

func rotate_torso():
	var aim_nozero = 8 if aim_dir == 0 else aim_dir
	var move_nozero = 8 if move_dir == 0 else move_dir
	
	# determine torso rotation
	if aim_nozero < move_nozero:
		torso_dir = wrapi(move_dir-1, 0, 8)
		# go one (out of 8) degree further if looking directly backwards
		vec_dif = move_nozero - aim_nozero
		if vec_dif == 4:
		#if vec_dif > 3:
			torso_dir = wrapi(torso_dir-1, 0, 8)
		elif vec_dif > 4:
			pass
	elif aim_nozero > move_nozero:
		torso_dir = wrapi(move_dir+1, 0, 8)
		# go one (out of 8) degree further if looking directly backwards
		vec_dif = aim_nozero - move_nozero
		if vec_dif == 4:
		#if vec_dif > 3:
			torso_dir = wrapi(torso_dir+1, 0, 8)
		elif vec_dif > 4:
			pass
	else:
		torso_dir = move_dir


func draw_player():
	# playy all the body parts
	head_player.play(player_state + str(aim_dir))
	torso_player.play(player_state + str(torso_dir))
	legs_player.play(player_state + str(move_dir))
	
	# play weapon-idle if aiming
	if look_vector:
		frontarm_player.play('idle' + str(torso_dir))
		backarm_player.play('idle' + str(torso_dir))
	else:
		frontarm_player.play(player_state + str(torso_dir))
		backarm_player.play(player_state + str(torso_dir))

func rotate_arms():
	if look_vector:
		arm_angle = look_angle - 1.5708
		frontarm_body.rotation = arm_angle
		backarm_body.rotation = arm_angle
#		frontarm_body.look_at(look_vector)
#		backarm_body.look_at(look_vector)
	else:
		frontarm_body.rotation = 0
		backarm_body.rotation = 0

func shoot():
	pass

func _ready():
	
	# set deadzones .......(?)
	InputMap.action_set_deadzone('move_up', deadzone)
	InputMap.action_set_deadzone('move_down', deadzone)
	InputMap.action_set_deadzone('move_left', deadzone)
	InputMap.action_set_deadzone('move_right', deadzone)
	InputMap.action_set_deadzone('aim_up', deadzone)
	InputMap.action_set_deadzone('aim_down', deadzone)
	InputMap.action_set_deadzone('aim_left', deadzone)
	InputMap.action_set_deadzone('aim_right', deadzone)

# builtin non timing critical
func _process(_delta):
	draw_player()
	pass

# builtin timing crticial
func _physics_process(delta):
	move_player(delta)
	aim_player()
	rotate_torso()
	rotate_arms()

# trigger based input
func _unhandled_input(event):
	#if Input.get_action_strength('shoot'):
	if event.is_action_pressed('shoot'):
		player_action = 'shoot'
		shoot()
	else:
		player_action = 'none'
