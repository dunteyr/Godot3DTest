extends CharacterBody3D

@export var speed = 14
@export var sprint_mod = 0.3
@export var jump_force = 20
@export var fall_acceleration = 75
@export var sensitivity = 0.01

@onready var head : Node3D = get_node("Head")
@onready var camera : Camera3D = get_node("Head/Camera3D")
@onready var gun : Node3D = get_node("Head/Gun")
@onready var shoot_raycast : RayCast3D = get_node("Head/Camera3D/Shoot_Target")

var target_velocity = Vector3.ZERO
var shoot_target = Vector3.ZERO;
var ray_distance = 100

#Happens once at beginning
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
#happens 60 times a frame
func _physics_process(delta):
	
	var direction = Vector3.ZERO;
	#get inputs
	if(Input.is_action_pressed("move_left")):
		direction.x -= 1
	if(Input.is_action_pressed("move_right")):
		direction.x += 1
	if(Input.is_action_pressed("move_forward")):
		direction.z -= 1
	if(Input.is_action_pressed("move_back")):
		direction.z += 1
		
	#normalize direction
	if(direction != Vector3.ZERO):
		direction = direction.normalized()
		
	#add direction to look direction
	direction = (head.basis * Vector3(direction.x, direction.y, direction.z)).normalized()
	
	if(Input.is_action_pressed("sprint")):
		target_velocity.x = direction.x * (speed + ((1 - sprint_mod) * speed))
		target_velocity.z = direction.z * (speed + ((1 - sprint_mod) * speed))
	else:
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
	
	#gravity and jump
	if(self.is_on_floor()):
		if(Input.is_action_just_pressed("jump")):
			target_velocity.y = jump_force
			
	elif not (self.is_on_floor()):
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	#set the node's velocity
	self.velocity = target_velocity
	#move using the velocity
	self.move_and_slide()
	
	

func _input(event):
	
	#camera movement and body rotation
	if event is InputEventMouseMotion:
		head.rotate_y(event.relative.x * sensitivity * -1)
		camera.rotate_x(event.relative.y * sensitivity * -1)
		camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		gun.rotate_x(event.relative.y * sensitivity * -1)
		gun.rotation.x = clampf(gun.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		
func _process(delta):
	if Input.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	shoot_raycast.set_target_position(Vector3(0.0, 0.0, -1.0) * ray_distance)
	shoot_target = shoot_raycast.get_collision_point();
	#update_aim()
		
	
func update_aim():
	if shoot_target != Vector3.ZERO:
		gun.look_at(shoot_target)
