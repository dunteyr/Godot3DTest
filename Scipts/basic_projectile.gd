extends RigidBody3D

@export var max_lifetime = 3.0
var current_lifetime = 0.0

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
	
	print(node)
	
	
	place_impact()
	queue_free()
	
	
func place_impact():
	var impact = impact_particles.instantiate()
	current_scene.add_child(impact)
	impact.set_global_position(get_global_position())
	impact.emitting = true
