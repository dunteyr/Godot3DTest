extends Node3D

@onready var animation : AnimationPlayer = get_node("AnimationPlayer")
@onready var skeleton : Skeleton3D = get_node("Armature/Skeleton3D")
@onready var mesh : MeshInstance3D = get_node("Armature/Skeleton3D/Stick")

func _ready():
	animation.play("Ragdoll Test/TestAnim")



func _process(_delta):
	if Input.is_action_just_pressed("Interact"):
		enable_ragdoll()


func enable_ragdoll():
	var active_bones : Array
	animation.stop()
	
	active_bones.push_back("Bone")
	skeleton.physical_bones_start_simulation(active_bones)
