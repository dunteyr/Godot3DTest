extends ColorRect

@onready var resume_button = find_child("Resume_Button")
@onready var quit_button = find_child("Quit_Button")

var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()
	
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(quit_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if is_paused:
			unpause()
		elif !is_paused:
			pause()

func pause():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	is_paused = true
	
	
func unpause():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()
	is_paused = false


func quit_game():
	get_tree().quit()
