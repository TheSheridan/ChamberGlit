## Bella's CharacterBody node for the worldmap.
## IDEA: Use this code for the default one too, that one needs refactoring.
extends CharacterBody3D


#region (Variables)
## Initial movement speed.
@export var initial_speed: float = 50
## sprite_int movement speed.
@export var sprite_int_speed: float = 500

var current_speed: float
@export var normal_speed: float = 2
@export var max_speed: float = 3	
@export var acceleration: float = 1
@export var deceleration: float = 120000

var current_velocity = Vector3.ZERO

@export var speed: float = initial_speed

# Camera
var camera_smoothing: float = 0.0
var camera_offset: Vector3
@export var camera_lerp_duration: float = 0.3
@onready var camera_default_pos = $Camera3D.position
@onready var camera_default_rotation = $Camera3D.rotation

var tween_lerp_a: Tween = null
var tween_lerp_b: Tween = null

# Camera lerp
@export var cam_lerp_amp = 3
@export var cam_lerp_weight = 0.00625

# Extra stuff
var stand_still: bool = false
var show_minimap: bool = false

# Fades
signal _fade_in
signal _fade_out
signal fade_finished

var fade_tween: Tween
@export var fade_duration: float = 0.125
@export var fade_color: Color = Color.BLACK
@export var not_change_fade_color: bool = false

# Walk sound
var walk_sound_switch: bool = false

@export var walk_sound_time_normal: float = 0.3
@export var walk_sound_time_running: float = 0.15
@onready var walk_sound_time: float = walk_sound_time_normal

@onready var BG = $Fade/Container/BG

# get_facing()
var axis_x: float
var axis_y: float
var axis_x_temp: float
var axis_y_temp: float

# Raycast
@export var ray_size = 0.5
@export var ray_strength = 0.5

# Textbox
@export var textbox_scale: float = 0.5
@export var textbox_fade_duration: float = 0.125

@export var text_to_send: DialogueResource

## Mostly handled by CharacterNPC, not Bella itself.
@export var can_talk: bool
## Takes the same value as "after_closing" in the textbox.
@export var after_closing: bool = false
#endregion


func _ready() -> void:
	speed = initial_speed
	current_speed = normal_speed
	
	BG.color = fade_color
	
	$MinimapMarker.modulate.a = 0
	
	fade_out()
	
	_fade_in.connect(fade_in.bind())
	_fade_out.connect(fade_out.bind())

func _process(delta: float) -> void:
	var input = get_input()
	
	# Run
	if Input.is_action_pressed('ui_cancel'):
		speed = sprite_int_speed
		current_speed = lerp(current_speed, max_speed, 0.5)

	if Input.is_action_just_released('ui_cancel'):
		speed = initial_speed
		current_speed = normal_speed
	
	# Move
	position += input * current_speed * delta
	
	# Place Bella on the ground all times
	position.z = 0
	
	#$Camera3D.position.z += 5 * delta
	
	switch_minimap()
	$MinimapMarker.rotation_degrees.z += 1
	
	walk_sound()
	
	# Lerp camera (for realz)
	move_raycast()
	lerp_camera()
	
	# Lerp camera
	# (i scammed myself, it's supposed to lerp the camera with camera_smoothing, but does nothing)
	if input.x < 0 or input.y < 0:
		lerp_camera_left()
	elif input.x > 0 or input.y > 0:
		lerp_camera_right()
		
	#print("Camera lerp: " + str(camera_smoothing))
	
	var camera_position = $Camera3D.position
	camera_position = lerp($Camera3D.position, camera_position, camera_smoothing)
	$Camera3D.position = camera_position

func _physics_process(delta) -> void:
	var input = get_input()
	var target_velocity = input.normalized() * current_speed

	# Accelerate or decelerate
	if input.length() > 0:
		current_velocity = target_velocity * (acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector3.ZERO, deceleration * delta)
	
	velocity = current_velocity
	move_and_slide()

func get_input() -> Vector3:
	var input = Vector3()
	
	if not stand_still:
		if Input.is_action_pressed("ui_up"):
			input.y += 1
		if Input.is_action_pressed("ui_down"):
			input.y -= 1
		if Input.is_action_pressed("ui_left"):
			input.x -= 1
		if Input.is_action_pressed("ui_right"):
			input.x += 1
	else:
		axis_x = input.x
		axis_y = input.y
		
	return input

func fade_in():	
	stand_still = true
	
	fade_tween = create_tween()
	fade_tween.tween_property(BG, "modulate:a", 1, fade_duration)
	
	%BGTimer.start(fade_duration)
	await %BGTimer.timeout
	
	fade_finished.emit()
	stand_still = false
	#print("Done!")
	
func fade_out():
	stand_still = true
	
	fade_tween = create_tween()
	fade_tween.tween_property(BG, "modulate:a", 0, fade_duration)
	
	%BGTimer.start(fade_duration / 2)
	await %BGTimer.timeout

	stand_still = false
	%BGTimer.start(fade_duration / 2)
	await %BGTimer.timeout
	
	fade_finished.emit()
	#print("Done!")

func switch_minimap():
	var cam = $Camera3D
	var spr = $Sprite3D
	var minimap_marker = $MinimapMarker
	var marker = $"../MinimapCameraMarker"
	
	var cam_lerp_force = 0.5
	var cam_minimap_zoom = 60.0
	var cam_pos_final = Vector3(marker.position.x, marker.position.y, cam_minimap_zoom)
	
	if Input.is_action_just_pressed("ui_select"):
		show_minimap = not show_minimap
		stand_still = not stand_still
	
	if show_minimap:
		cam.rotation.x = lerp(cam.rotation.x, 0.0, cam_lerp_force)
		cam.position = lerp(cam.position, cam_pos_final, cam_lerp_force)
		spr.modulate.a = lerp(spr.modulate.a, 0.0, cam_lerp_force)
		minimap_marker.modulate.a = lerp(minimap_marker.modulate.a, 1.0, cam_lerp_force)
	else:
		spr.modulate.a = lerp(spr.modulate.a, 1.0, cam_lerp_force)
		cam.rotation.x = lerp(cam.rotation.x, camera_default_rotation.x, cam_lerp_force)
		cam.position = lerp(cam.position, camera_default_pos, cam_lerp_force)
		minimap_marker.modulate.a = lerp(minimap_marker.modulate.a, 0.0, cam_lerp_force)

func walk_sound():
	var input = get_input()
	
	if input != Vector3.ZERO:
		if not walk_sound_switch:
			walk_sound_switch = true
			$WalkSound.play()
			$WalkSound/Timer.start(walk_sound_time)
			
func _on_timer_timeout() -> void:
	walk_sound_switch = false
	
func move_raycast():
	var input = get_input()
	var ray = $RayCast3D
	
	match input:
		# Repetitive code... Is there a way to simplify this?
		Vector3.UP:
			ray.target_position = Vector3.UP * ray_size
		Vector3.DOWN:
			ray.target_position = Vector3.DOWN * ray_size
		Vector3.LEFT:
			ray.target_position = Vector3.LEFT * ray_size
		Vector3.RIGHT:
			ray.target_position = Vector3.RIGHT * ray_size
			
	# Axis stuff
	if ray.target_position.x != 0:
		axis_x = ray.target_position.x
	else: 
		axis_x = 0
		
	if ray.target_position.y != 0:
		axis_y = ray.target_position.y
	else: 
		axis_y = 0
	
func lerp_camera():
	#var cam_h_offset = lerp($Camera3D.h_offset, axis_x * cam_lerp_amp, cam_lerp_weight)
	#var cam_v_offset = lerp($Camera3D.v_offset, axis_y * cam_lerp_amp, cam_lerp_weight)
	
	camera_offset = lerp(camera_offset, Vector3(axis_x, axis_y, 0) * cam_lerp_amp, cam_lerp_weight)
		
	if not stand_still:	
		$Camera3D.position = camera_default_pos + camera_offset
		
	#print("axis_x: " + str(axis_x) + ", axis_y: " + str(axis_y) + '\n')

# TODO: Rename lerp_camera_left/right() to smooth_camera_lerp/right()
func lerp_camera_left():
	if is_instance_valid(tween_lerp_a):
		tween_lerp_a.kill()
	
	tween_lerp_a = create_tween()

	tween_lerp_a.set_ease(Tween.EASE_IN)
	tween_lerp_a.set_trans(Tween.TRANS_CUBIC)
	tween_lerp_a.tween_property(self, 'camera_smoothing', 1.0, camera_lerp_duration)

	tween_lerp_a.finished.connect(_on_tween1_finished.bind(), CONNECT_ONE_SHOT)
	
func _on_tween1_finished():
	if is_instance_valid(tween_lerp_a):
		if tween_lerp_a.is_connected("finished", _on_tween1_finished.bind()):
			tween_lerp_a.finished.disconnect(_on_tween1_finished)
			#print("Tween 1 disconnected.")

func lerp_camera_right():
	if is_instance_valid(tween_lerp_b):
		tween_lerp_b.kill()
		#print("Tween 2 killed.")
	
	tween_lerp_b = create_tween()
	tween_lerp_b.set_ease(Tween.EASE_OUT)
	tween_lerp_b.set_trans(Tween.TRANS_CUBIC)
	tween_lerp_b.tween_property(self, 'camera_smoothing', 0.0, camera_lerp_duration)

	tween_lerp_b.finished.connect(_on_tween2_finished.bind(), CONNECT_ONE_SHOT)
	
func _on_tween2_finished():
	#print("Tween 2 finished.")

	if is_instance_valid(tween_lerp_b):
		if tween_lerp_b.is_connected("finished", _on_tween2_finished.bind()):
			tween_lerp_b.finished.disconnect(_on_tween2_finished)
			#print("Tween 2 disconnected.")

func npc_start_now():
	$ExampleBalloon/FadeAnim.play("fade_in")
	$ExampleBalloon.start()

func save():
	var save_dict = {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		
		"test": "This is a test :3"
	}
	return save_dict
