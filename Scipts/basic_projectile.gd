extends RigidBody3D

@export var max_lifetime = 3.0
var current_lifetime = 0.0
var impact_position
var impact_direction

@onready var impact_raycast : RayCast3D = get_node("Decal_Cast")
@onready var bullet_hole_decal = preload("res://Prefabs/bullet_hole.tscn")
@onready var impact_particles = preload("res://Prefabs/Particles/bullet_impact.tscn")
@onready var current_scene = get_tree().get_root()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 20
	self.body_entered.connect(on_bullet_collision)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#if the bullet has been alive for too long without collision, delete it
	current_lifetime += delta
	if current_lifetime >= max_lifetime:
		queue_free()
	

func on_bullet_collision(node):
	impact_position = global_position
	
	place_impact()
	queue_free()
	
	
func place_impact():
	
	place_bullet_hole()
	
	var impact = impact_particles.instantiate()
	current_scene.add_child(impact)
	impact.set_global_position(get_global_position())
	impact.emitting = true


func get_impact_normal():
	
	if impact_raycast.is_colliding():
		var normal = impact_raycast.get_collision_normal()
		return normal
	else:
		print("No Collision")
		return Vector3(0,0,0)


func place_bullet_hole():
	var impact_normal = get_impact_normal()	
	print(impact_normal)
	
	var bullet_hole = bullet_hole_decal.instantiate()
	current_scene.add_child(bullet_hole)
	bullet_hole.set_global_position(get_global_position())
	
	#for some reason Node3D look_at() function fails if it needs to look straight up or straight down
	#so in those cases just rotate the bullet hole manually
	if impact_normal == Vector3.UP:
		bullet_hole.global_rotation_degrees.x -= 90
	elif impact_normal == Vector3.DOWN:
		bullet_hole.global_rotation_degrees.x += 90
	else:
		bullet_hole.look_at(get_global_position() - impact_normal)
