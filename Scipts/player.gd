extends CharacterBody3D

@export var speed = 14
@export var sprint_mod = 0.3
@export var jump_force = 20
@export var fall_acceleration = 75
@export var sensitivity = 0.005
@export var fire_rate = 0.05
@export var bullet_speed = 200
@export var magazine_size = 30
@export var reload_speed = 1.4
@export var camera_recoil_amount = 0.2
@export var recoil_amount = 0.003
@export var recoil_damping = 0.1
@export var position_recoil_amount = 8
@export var recoil_return_modifier = 0.1
@export var recoil_fire_rate_scaling = true

@onready var player_ui = get_node("Player_UI")
@onready var current_scene = get_tree().get_root()
@onready var head : Node3D = get_node("Head")
@onready var camera : Camera3D = get_node("Head/Camera3D")
@onready var gun : Node3D = get_node("Head/Gun")
@onready var projectile = preload("res://Prefabs/basic_projectile.tscn")
@onready var proj_spawn : Node3D = get_node("Head/Gun/Rifle_Body/Proj_Spawn")
@onready var shoot_raycast : RayCast3D = get_node("Head/Camera3D/Shoot_Target")
@onready var animation : AnimationPlayer = get_node("Head/Gun/AnimationPlayer")
@onready var muzzle_flash : CPUParticles3D = get_node("Head/Gun/Rifle_Body/Muzzle_Flash")

var is_sprinting = false
var is_reloading = false
var current_reload_time = 0.0
var target_velocity = Vector3.ZERO
var shoot_target = Vector3.ZERO
var ray_distance = 100
var is_firing = false
var fire_timer = fire_rate
var shots_remaining = magazine_size
var current_shots_fired = 0
var current_recoil_vel = 0.0
var pre_recoil_gun_pos

signal bullet_fired(shots_remaining)
signal reloaded(mag_size)

#Happens once at beginning
func _ready():
	pre_recoil_gun_pos = gun.position
	
	
#happens 60 times a frame
func _physics_process(delta):
	
	var direction = Vector3.ZERO;
	#get inputs
	if(Input.is_action_pressed("move_left")):
		direction.x -= 1
	if(Input.is_action_pressed("move_right")):
		direction.x += 1
	if(Input.is_action_pressed("move_forward")):
		direction.z -= 1
	if(Input.is_action_pressed("move_back")):
		direction.z += 1
		
	#normalize direction
	if(direction != Vector3.ZERO):
		direction = direction.normalized()
		
	#add direction to look direction
	direction = (basis * Vector3(direction.x, direction.y, direction.z)).normalized()
	
	if(Input.is_action_pressed("sprint")):
		#cancel the reload if player sprints while reloading
		if is_reloading:
			reload(delta, true) #argument makes the reload cancel itself
			
		target_velocity.x = direction.x * (speed + ((1 - sprint_mod) * speed))
		target_velocity.z = direction.z * (speed + ((1 - sprint_mod) * speed))
		is_sprinting = true
		animation.play("sprinting")
	else:
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
		
		#stop sprinting animation
		if animation.is_playing():
			if animation.get_current_animation() == "sprinting":
				is_sprinting = false
				animation.play("RESET")
		
			
	
	#gravity and jump
	if(self.is_on_floor()):
		if(Input.is_action_just_pressed("jump")):
			target_velocity.y = jump_force
			
	elif not (self.is_on_floor()):
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	#set the node's velocity
	self.velocity = target_velocity
	#move using the velocity
	self.move_and_slide()
	
	#reload input listening
	if Input.is_action_just_pressed("reload"):
		#can't reload while sprinting or with a full mag
		if !is_sprinting && shots_remaining < magazine_size:		
			reload(delta)
	
	#reload is called every frame to check if the animation is done. Could be done using animation player signal
	if is_reloading:
		reload(delta)
		
func _input(event):
	
	#camera movement and body rotation
	if event is InputEventMouseMotion:
		rotate_y(event.relative.x * sensitivity * -1)
		head.rotate_x(event.relative.y * sensitivity * -1)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event is InputEvent:
		
		#sets isFiring once fire is clicked/held down
		if event.is_action_pressed("fire"):
			if !is_firing:
				is_firing = true
		
		#sets isFiring to false and resets fire rate timer
		elif event.is_action_released("fire"):
			is_firing = false
			fire_timer = fire_rate
			
			muzzle_flash.emitting = false
		
func _process(delta):
	
	if !is_sprinting:
		fire_projectile(delta)
		

func fire_projectile(delta):
	#manages recoil
	recoil(delta)
	
	if shots_remaining > 0 && !is_reloading:
		if is_firing:
			muzzle_flash.emitting = false
			#on the first shot set timer to 0, so first shot happens on click
			if current_shots_fired == 0:
				fire_timer = 0
			else:
				#count down every frame
				fire_timer -= delta
			
			#fire once the timer hits zero
			if fire_timer <= 0:
				apply_recoil_force(recoil_fire_rate_scaling)
				#animation.play("recoil")
				#lifetime has to be less than fire_rate
				muzzle_flash.lifetime = 0.03
				muzzle_flash.one_shot = true
				muzzle_flash.emitting = true
				#create bullet and set rotation/position
				var bullet : RigidBody3D = projectile.instantiate()
				current_scene.add_child(bullet)
				bullet.set_global_position(proj_spawn.get_global_position())
				bullet.set_global_rotation(gun.get_global_rotation())
				
				#send it
				bullet.apply_impulse(-bullet.basis.z * bullet_speed)
				#turn on smoke trail
				bullet.find_child("Smoke_Trail").emitting = true
				#reset timer for next bullet
				fire_timer = fire_rate
				current_shots_fired += 1
				shots_remaining -= 1
				bullet_fired.emit(shots_remaining)
				
			else:
				muzzle_flash.emitting = false
		else:
			current_shots_fired = 0
	else:
		#reload is run every frame that the player is reloading in _process.
		#!is_reloading stops reload from running another time every frame.
		#is_firing makes it so if you cancel the reload by sprinting, it doesn't automatically
		#try to reload again. The player has to press R or try to fire
		if !is_reloading && is_firing:
			reload(delta)
		
	

func apply_recoil_force(scale_with_fire_rate = false):
	
	if !scale_with_fire_rate:
		current_recoil_vel = recoil_amount
	else:
		if fire_rate >= 0.175:
			current_recoil_vel = recoil_amount + (fire_rate / 50)
		else:
			current_recoil_vel = recoil_amount + (fire_rate / 100)
		
		
func recoil(delta):
	var max_angle = 5.0
	var max_pos_diff = 0.1
	var max_pos = pre_recoil_gun_pos.z + max_pos_diff
	var pos_mod = position_recoil_amount
	var return_mod = recoil_return_modifier
	var camera_recoil_threshold = max_angle - (max_angle / 20)
	
	#camera recoil
	#this conditional fixes jitter
	if current_recoil_vel != 0.0:
		if head.rotation_degrees.x <= 80:
			if gun.rotation_degrees.x > camera_recoil_threshold:
				var target = Vector3(head.rotation.x + camera_recoil_amount, 0.0, 0.0)
				head.rotation = head.rotation.lerp(target, delta)
	
	#recoil
	if current_recoil_vel > 0:
		#rotation recoil
		if gun.rotation_degrees.x <= max_angle:
			gun.rotate_x(current_recoil_vel)	
			current_recoil_vel -= recoil_damping * delta
		elif gun.rotation_degrees.x >= max_angle:
			gun.rotation_degrees.x = max_angle
			
		#position recoil
		if gun.position.z <= max_pos:
			gun.position.z += (current_recoil_vel * pos_mod)
		else:
			gun.position.z = max_pos
			
	#recoil correction	
	elif current_recoil_vel <= 0:
		
		#rotation correction
		if gun.rotation_degrees.x > 0:
			#return_mod makes the return recoil slower
			gun.rotate_x(current_recoil_vel * return_mod)
			current_recoil_vel -= recoil_damping * delta
		else:
			gun.rotation_degrees.x = 0
		
		#position correction
		if gun.position.z > pre_recoil_gun_pos.z:
			gun.position.z += (current_recoil_vel * pos_mod)
		else:
			gun.position.z = pre_recoil_gun_pos.z


func reload(delta, cancel_reload = false):
	
	#the threshold is based on normal speed, but the animation is played faster
	var cancel_forgive_thresh = 2.1
	var scaled_forgive = cancel_forgive_thresh / reload_speed
	
	if !cancel_reload:		
		#when starting reload. play the animation and set is_reloading
		if !is_reloading:
			current_reload_time = 0.0
			is_reloading = true
			animation.play("reload", -1, reload_speed)
		#if gun is currently reloading
		elif is_reloading:
			if animation.is_playing():
				#if reload animation isn't playing set the new shots remaining and emit signal
				if animation.current_animation != "reload":
					shots_remaining = magazine_size
					reloaded.emit(shots_remaining)
					is_reloading = false
				else:
					current_reload_time += delta
			#if an animation is playing that isnt reload, set new shots remaining and emit signal
			else:
				shots_remaining = magazine_size
				reloaded.emit(shots_remaining)
				is_reloading = false
				
	#if the reload animation has been playing for longer than the forgiveness time
	#complete the reload. If it hasn't, stop the reload without completing it
	elif cancel_reload:
		if animation.is_playing() && animation.current_animation == "reload":
			if current_reload_time >= scaled_forgive:
				shots_remaining = magazine_size
				reloaded.emit(shots_remaining)
				is_reloading = false
			else:
				is_reloading = false		
