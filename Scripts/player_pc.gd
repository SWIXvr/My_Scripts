extends CharacterBody3D
@onready var cam: Camera3D = $Camera3D
@onready var orientation: Node3D = $Orientation
@onready var velocityTR: Label = %Label


var speedTracker = 0
const SPEED = 5.0
const crouched_speed = 3.2
const sprint_speed = 8.0
const JUMP_VELOCITY = 4.5
const SlideSpeed = 2
const sens = 0.2
var crouching = false
var jumped = false
var slide = false
var sprinting = false
var standing =  Vector3(1, 1, 1)
var crouched = Vector3(1, 0.6, 1)

var Head_bob_freq = 2.0
var Head_bob_amp = 0.08
var head_bob = 0.0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.y -= event.relative.x * sens
		cam.rotation_degrees.x -= event.relative.y * sens
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -80, 80)
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumped = true
	else:
		jumped = false
		
		
	if Input.is_action_just_pressed("sprint"):
		sprinting = true
	elif Input.is_action_just_released("sprint"):
		sprinting = false
		
		
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		scale =  scale.slerp(crouched, delta * 22)
		crouching = true
		#if velocity.length() > 4.5:
		#	slide = true
		#elif velocity.length() < 4:
		#	slide = false
	elif Input.is_action_just_released("crouch"):
		scale = scale.slerp(standing, delta * 22)
		crouching = false
	#elif velocity.length() < 4:
	#		slide = false
	
	if !crouching and !sprinting and slide == false:
		speedTracker = SPEED
	elif crouching == true and sprinting == false:
		speedTracker = crouched_speed
	elif crouching == false and sprinting == true:
		speedTracker = sprint_speed
	
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir_2D = Input.get_vector("A", "D", "W", "S")
	var input_dir_3D = Vector3(input_dir_2D.x, 0, input_dir_2D.y)
	var direction = (cam.transform.basis * input_dir_3D).normalized()
	##var slideDir = (cam.transform.basis * Vector3(1.0, 0, 1.0)).normalized()
	if is_on_floor():
		if direction:
			if  jumped == false and slide == false:
				velocity.x = direction.x * speedTracker
				velocity.z = direction.z * speedTracker 
			if  jumped == true and slide == false:
				velocity.x = direction.x * speedTracker * 1.3
				velocity.z = direction.z * speedTracker * 1.3
			#elif slide == true:
			#	velocity.x = -slideDir.x * SlideSpeed * velocity.length() / 1.2
			#	velocity.z = slideDir.z * SlideSpeed * velocity.length()  / 1.2
		else:
			if slide == true:
				velocity.x = lerp(velocity.x, direction.x * speedTracker , delta * 3)
				velocity.z = lerp(velocity.z, direction.z * speedTracker , delta * 3)
			else:
				velocity.x = lerp(velocity.x, direction.x * speedTracker , delta * 8)
				velocity.z = lerp(velocity.z, direction.z * speedTracker , delta * 8)
			
	else:
		velocity.x = lerp(velocity.x, direction.x * speedTracker , delta * 4)
		velocity.z = lerp(velocity.z, direction.z * speedTracker , delta * 4)
	
	head_bob += delta * velocity.length() * float(is_on_floor())
	cam.transform.origin = _headBob(head_bob)
	
	velocityTR.text = str(velocity.length())
	
	move_and_slide()

func _headBob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * Head_bob_freq) * Head_bob_amp
	pos.x = sin(time * Head_bob_freq) * Head_bob_amp
	return pos
	
