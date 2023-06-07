extends Node3D

@export var start_animated = false

@onready var animation : AnimationPlayer = get_node("AnimationPlayer")
@onready var skeleton : Skeleton3D = get_node("Armature/Skeleton3D")
@onready var mesh : MeshInstance3D = get_node("Armature/Skeleton3D/Character_Cube002")

# Called when the node enters the scene tree for the first time.
func _ready():
	if start_animated:
		animation.play("Low Poly Character/Low Poly Idle")
	else:
		animation.play("Low Poly Character/Low Poly T Pose")	
		
	#animation.play("Low Poly Character/Low Poly Idle")
	make_bones_visible()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Interact"):
		#animation.play("Low Poly Character/Low Poly T Pose")
		enable_ragdoll()


func enable_ragdoll():
	var active_bones : Array

	
	active_bones.push_back("mixamorig_RightFoot")
	active_bones.push_back("mixamorig_LeftFoot")
	active_bones.push_back("mixamorig_RightLeg")
	active_bones.push_back("mixamorig_LeftLeg")
	active_bones.push_back("mixamorig_RightUpLeg")
	active_bones.push_back("mixamorig_LeftUpLeg")
	#hips makes the whole ragdoll fall
#	active_bones.push_back("mixamorig_Hips")
#	active_bones.push_back("mixamorig_Spine")
#	active_bones.push_back("mixamorig_Spine2")
#	active_bones.push_back("mixamorig_Head")
	active_bones.push_back("mixamorig_LeftArm")
#	active_bones.push_back("mixamorig_LeftForeArm")
#	active_bones.push_back("mixamorig_LeftHand")
#	active_bones.push_back("mixamorig_RightArm")
#	active_bones.push_back("mixamorig_RightForeArm")
#	active_bones.push_back("mixamorig_RightHand")
	
	skeleton.physical_bones_start_simulation(active_bones)
	

func make_bones_visible():
	var bones = skeleton.find_children("*")
	for node in bones:
		node.set_visible(true)
	
	
	
	
