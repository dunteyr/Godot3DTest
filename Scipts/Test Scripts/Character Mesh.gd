extends Node3D

var ragdoll = false

@onready var animation : AnimationPlayer = get_node("AnimationPlayer")
@onready var skeleton : Skeleton3D = get_node("Armature/Skeleton3D")
@onready var mesh : MeshInstance3D = get_node("Armature/Skeleton3D/Character_Cube002")

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("Low Poly Character/Low Poly T Pose")	
	#animation.play("Low Poly Character/Low Poly Idle")
	mesh.set_visible(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Interact"):
		#animation.play("Low Poly Character/Low Poly T Pose")
		enable_ragdoll()


func enable_ragdoll():
	var active_bones : Array
	var right_foot = skeleton.find_bone("mixamorig_RightFoot")
	
	active_bones.push_back(skeleton.get_bone_name(right_foot))
	
	skeleton.physical_bones_start_simulation(active_bones)
	
