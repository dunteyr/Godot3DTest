extends Node3D

@onready var animation = get_node("AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("Ragdoll Test/TestAnim")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
