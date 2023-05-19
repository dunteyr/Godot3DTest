extends Node3D

var mouse_mov
var base_gun_pos
@export var rot_correction_spd = 5
@export var left_rot_amt = 0.2
@export var right_rot_amt = 0.2
@export var sway_threshold = 5

@export var up_pos_diff = 10
@export var down_pos_diff = 10

@export var sway_correction_spd = 5
@export var left_sway : float
@export var right_sway : float

@onready var head = get_parent().get_node(".")

# Called when the node enters the scene tree for the first time.
func _ready():
	base_gun_pos = position


func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement = get_movement()
	
	#left right weapon rotation (view based)
	if mouse_mov != null:
		if mouse_mov > sway_threshold:
			rotation = rotation.lerp(Vector3(rotation.x,-left_rot_amt, 0.0), rot_correction_spd * delta)
		elif mouse_mov < -sway_threshold:
			rotation = rotation.lerp(Vector3(rotation.x,right_rot_amt, 0.0), rot_correction_spd * delta)
		else:
			rotation = rotation.lerp(Vector3(rotation.x,0.0, 0.0), rot_correction_spd * delta)
			
	# up down position adjustment (view based)
	if head.rotation.x > 0:
		position = Vector3(position.x, base_gun_pos.y + (up_pos_diff * (head.rotation.x / 80)), position.z)
	elif head.rotation.x < 0:
		position = Vector3(position.x, base_gun_pos.y + (down_pos_diff * (abs(head.rotation.x / 80))), position.z)
			
	#left right weapon sway (movement based)		
	if movement.x > 0:
		position = position.lerp(Vector3(base_gun_pos.x - left_sway, position.y, position.z), movement.x * delta * sway_correction_spd)
	elif movement.x < 0:
		position = position.lerp(Vector3(base_gun_pos.x + right_sway, position.y, position.z), abs(movement.x * delta * sway_correction_spd))
	else:
		position = position.lerp(Vector3(base_gun_pos.x, position.y, position.z), (1 - movement.x) * delta * sway_correction_spd)
	

func get_movement():
	var direction = Vector3.ZERO
	
	if(Input.is_action_pressed("move_left")):
		direction.x -= 1
	if(Input.is_action_pressed("move_right")):
		direction.x += 1
		
	return direction
