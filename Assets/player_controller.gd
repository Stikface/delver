extends CharacterBody3D

const MOVE_SPEED = 5.0

#get project's universal gravity setting
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var look_dir: Vector2
var look_sensitivity = 50
var keyboard_look_multiplier = 0.04
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var camera_anchor: Marker3D = $CameraAnchor

var mouse_capture = false

#this runs for each physics tick.
#functions with _ at the start are supposed to be private and not accessed by other scripts
func _physics_process(delta):
	_camera_handler(delta)
	_movement_handler(delta)

#this gets called every time any kind of input happens
func _input(event: InputEvent):
	#input events are defined by the InputMap but mouse inputs are Their Own Thing
	#event.relative is the amount the input variable changed since the last frame
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	
	#toggle mouse capture
	if Input.is_action_pressed("Pause"):
		mouse_capture = !mouse_capture #flips the boolean to the opposite of what it already was. ! = "NOT"
		if mouse_capture:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _camera_handler(delta: float, sensitivity_modifier: float = 1.0):
	#get input for keyboard-look
	var input_dir = Input.get_vector("LookLeft","LookRight","LookUp","LookDown") * keyboard_look_multiplier
	#add keyboardlook input to mouselook input
	look_dir += input_dir
	
	#rotate the whole player node left and right
	rotation.y -= look_dir.x * look_sensitivity * delta
	
	#rotate just the camera-anchor up and down. clamp() so you can't break your neck looking up and down
	camera_anchor.rotation.x = clamp(camera_anchor.rotation.x - look_dir.y * look_sensitivity * sensitivity_modifier * delta, -1.5, 1.5) #clamp bounds are in radians
	
	#interpolate camera anchor between physics ticks to prevent jittering when screen refresh is faster than physics ticks
	camera_pivot.global_transform = camera_anchor.get_global_transform_interpolated()
	
	look_dir = Vector2.ZERO

func _movement_handler(delta: float):
	#falling down
	if not is_on_floor():
		velocity.y -= gravity * delta

	#we don't have jumping so im not adding a jump function

	# get input directions for movement. this gives intensity 0.0 to 1.0 if using analog sticks
	var input_dir = Input.get_vector("Left","Right","Up","Down")
	# create a Vector3 using input directions. normalized() stops the "diagonal is faster" thing that happens in DOOM
	var movement_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if movement_dir:
		#if there's input, set velocity to SPEED (multiplied by input magnitude for analog sticks)
		velocity.x = movement_dir.x * MOVE_SPEED
		velocity.z = movement_dir.z * MOVE_SPEED
	else:
		#set velocity to 0 when no input
		velocity.x = 0
		velocity.z = 0

	#builtin function that handles movement and slides when it crashes into things
	move_and_slide()
	
