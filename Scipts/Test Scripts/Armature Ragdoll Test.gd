extends Node3D

@onready var animation : AnimationPlayer = get_node("AnimationPlayer")
@onready var skeleton : Skeleton3D = get_node("Armature/Skeleton3D")
@onready var mesh : MeshInstance3D = get_node("Armature/Skeleton3D/Stick")

func _ready():
	animation.play("Ragdoll Test/TestAnim")
	make_bones_visible()



func _process(_delta):
	if Input.is_action_just_pressed("Interact"):
		enable_ragdoll()


func enable_ragdoll():
	var active_bones : Array
	#animation.stop()
	
	active_bones.push_back("Bone")
	active_bones.push_back("Bone.005")
	active_bones.push_back("Bone.004")
	active_bones.push_back("Bone.003")
	active_bones.push_back("Bone.002")
	active_bones.push_back("Bone.001")
	skeleton.physical_bones_start_simulation(active_bones)


func make_bones_visible():
	var bones = skeleton.find_children("*")
	for node in bones:
		node.set_visible(true)
