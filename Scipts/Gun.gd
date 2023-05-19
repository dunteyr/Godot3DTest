extends Node3D

var mouse_mov
@export var lerp_val = 5
@export var left_sway_amt : float
@export var right_sway_amt : float
@export var sway_threshold = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if mouse_mov != null:
		if mouse_mov > sway_threshold:
			rotation = rotation.lerp(Vector3(rotation.x,-left_sway_amt, 0.0), lerp_val * delta)
		elif mouse_mov < -sway_threshold:
			rotation = rotation.lerp(Vector3(rotation.x,right_sway_amt, 0.0), lerp_val * delta)
		else:
			rotation = rotation.lerp(Vector3(rotation.x,0.0, 0.0), lerp_val * delta)
			
		
			
			
	


