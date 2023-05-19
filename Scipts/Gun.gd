extends Node3D

var mouse_mov
var base_gun_pos
@export var correction_spd = 5
@export var left_sway_amt : float
@export var right_sway_amt : float
@export var sway_threshold = 5

@export var up_pos_diff : Vector3
@export var down_pos_diff : Vector3

@onready var head = get_parent().get_node(".")

# Called when the node enters the scene tree for the first time.
func _ready():
	base_gun_pos = position


func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#left right weapon sway
	if mouse_mov != null:
		if mouse_mov > sway_threshold:
			rotation = rotation.lerp(Vector3(rotation.x,-left_sway_amt, 0.0), correction_spd * delta)
		elif mouse_mov < -sway_threshold:
			rotation = rotation.lerp(Vector3(rotation.x,right_sway_amt, 0.0), correction_spd * delta)
		else:
			rotation = rotation.lerp(Vector3(rotation.x,0.0, 0.0), correction_spd * delta)
			
	# up down position adjustment
	if head.rotation.x > 0:
		position = base_gun_pos + (up_pos_diff * (head.rotation.x / 80))
	elif head.rotation.x < 0:
		position = base_gun_pos + (down_pos_diff * (abs(head.rotation.x / 80)))
			
			
	


