extends Node

@export var max_bullet_holes = 80

@onready var scene_tree = get_tree()

var bullet_holes : Array
var bullet_hole_group = "bullet_holes"

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_tree.node_added.connect(bullet_hole_despawner)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func bullet_hole_despawner(node):
	#if node added to scene tree is a bullet hole, add it to the bullet holes array
	if node.is_in_group(bullet_hole_group):
		bullet_holes.push_back(node)
		
		#if there are too many bullet holes, delete the oldest one
		if bullet_holes.size() >= max_bullet_holes:
			#find out how many holes to remove
			var holes_to_remove = bullet_holes.size() - max_bullet_holes
			#remove oldest hole however many times is needed
			for i in range(holes_to_remove):
				bullet_holes[i].queue_free()
				bullet_holes.pop_front()
