extends Node3D

@export var ragdoll = false

@onready var animation : AnimationPlayer = get_node("AnimationPlayer")
@onready var skeleton : Skeleton3D = get_node("Armature/Skeleton3D")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if ragdoll:
		enable_ragdoll()
	else:		
		animation.play("Low Poly Character/Low Poly Idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func enable_ragdoll():
	skeleton.physical_bones_start_simulation()
