extends Control

@onready var player = get_parent()
@onready var mag_size_label = get_node("Ammo_Container/Mag_Size_Label")
@onready var mag_remaining_label = get_node("Ammo_Container/Mag_Remaining_Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.bullet_fired.connect(update_ammo_label)
	init_ammo_label(player.magazine_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_ammo_label(new_label):
	mag_remaining_label.set_text(str(new_label))


func init_ammo_label(mag_size):
	mag_size_label.set_text(str(mag_size))
	mag_remaining_label.set_text(str(mag_size))
