
# Refactored!
## Same script as chr_bell.gd but friction is disabled.
extends CharacterBody2D


## Sets the _camera_ zoom (default 1).
@export var camera_zoom = 1.0

@export var camera_lerp_duration: float = 0.3
@export var camera_magnitude: float = 3

## Sets how large is the $Raycast.
@export var ray_size = 50
## Strength of the $Raycast movement.
@export var ray_strength = 0.5

## Sets how much the _camera_ pans when looking to sides.
@export var look_beyond_power = 200
## Time taken while looking to sides.
@export var look_beyond_time = 0.3
## Checks if looking to sides takes a single press.
@export var looked_beyond_once: bool = false

## Initial movement speed.
@export var initial_speed: float = 600
## sprite_int movement speed.
@export var sprite_int_speed: float = 1000

# New stuff
@export var acceleration: float = 2000
@export var deceleration: float = 15000	
@export var normal_speed: float = 180
@export var max_speed: float = 300
var current_speed: float

var current_velocity = Vector2.ZERO

@export var tile_map: TileMapLayer


@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')

var speed: float = initial_speed
var directed_velocity = Vector2.ZERO
var direction = Vector2.ZERO

var sprite_speed: float

var camera_smoothing: float = 0.0

var tween_lerp_a: Tween = null
var tween_lerp_b: Tween = null

var tween_look_x: Tween
var tween_look_y: Tween

var axis_x: float
var axis_y: float
var axis_x_temp: float
var axis_y_temp: float

var position_previous: Vector2

var is_camera_zoom_on = true
var get_input_temp_position: Vector2 = Vector2(0, 0)

# Textbox
@export var textbox_scale: float = 0.5
@export var textbox_fade_duration: float = 0.125

var stand_still: bool = false
## Takes the same value as "after_closing" in the textbox.
@export var after_closing: bool = false

@export var text_to_send: DialogueResource

## Mostly handled by CharacterNPC, not Bella itself.
@export var can_talk: bool

# Fade
signal _fade_in
signal _fade_out
signal fade_finished

var fade_tween: Tween
@export var fade_duration: float = 0.125
@export var fade_color: Color = Color.BLACK


func _ready():
	# Default animation
	$Sprite.animation = "idle_down"
	$Sprite.play()
	$Sprite.speed_scale = 1
	#print($Sprite.get_playing_speed())
	
	#$Textbox.show()
	
	speed = initial_speed
	current_speed = normal_speed
	
	$ColorRect.show()
	
	_fade_in.connect(fade_in.bind())
	_fade_out.connect(fade_out.bind())
	
	_fade.hide()
	
	after_closing = $ExampleBalloon.after_closing

var walk_sound_bool: bool = true
func _process(_delta) -> void:
	if is_camera_zoom_on:
		$Camera.zoom = Vector2(camera_zoom, camera_zoom)
		# TODO: Figure out a way to match the ratio
		#$Textbox.scale = Vector2(textbox_scale, textbox_scale)
	
	# looked_beyond
	# if Input.is_action_just_pressed("ui_select"):
	# 	match looked_beyond_once:
	# 		false: looked_beyond_once = true
	# 		true: looked_beyond_once = false

	# match looked_beyond_once:
	# 	false: look_beyond()
	# 	true: look_beyond_once()
	# 	_: pass
	
	if $Ray.target_position.x != 0:
		axis_x_temp = $Ray.target_position.x
	if $Ray.target_position.y != 0:
		axis_y_temp = $Ray.target_position.y
		
	if Input.is_action_pressed('ui_cancel'):
		speed = sprite_int_speed
		current_speed = lerp(current_speed, max_speed, 0.5)
	if Input.is_action_just_released('ui_cancel'):
		speed = initial_speed
		current_speed = normal_speed
	
	var direction_input = get_input()
	if direction_input.x < 0 or direction_input.y < 0:
		#print("Calling lerp_camera_left()")
		lerp_camera_left()  # Change to left/right based on input direction
	elif direction_input.x > 0 or direction_input.y > 0:
		#print("Calling lerp_camera_right()")
		lerp_camera_right()
		
	#while direction_input != Vector2.ZERO:
		#if walk_sound_bool:
			#$WalkSound.play()
		#
		#walk_sound_bool = false
		#$WalkSound/Timer.start(0.5)
		#print($WalkSound/Timer.time_left)
		#await $WalkSound/Timer.timeout
		#walk_sound_bool = true
		
	get_input_temp_position = get_input()
	position_previous = position
	
	# That perky camera offset...
	var camera_lerp: Vector2 = lerp(
		$Camera.offset, Vector2(axis_x, axis_y) * 15, 0.05)
		
	if not stand_still:	
		get_facing()
		$Camera.offset = camera_lerp
		camera_smoothing = 0 # <- doesn't work T_T
	
	#$Textbox.position = -(_sgt.window_size / 2) + $Camera.offset
	
	#$Textbox.position = position + $Camera.offset
	
	$ColorRect.color = fade_color

func _physics_process(delta) -> void:
	var input = get_input()

	var target_velocity = input.normalized() * current_speed

	# Accelerate or decelerate
	if input.length() > 0:
		current_velocity = target_velocity * (acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	velocity = current_velocity
	move_and_slide()


	# Misc
	# get_facing()

	var camera_position = $Camera.position
	#$Camera.offset = lerp($Camera.offset, velocity / 16, 0.5)
	camera_position = lerp($Camera.position, camera_position, camera_smoothing)
	$Camera.position = camera_position

	# Animation speed
	$Sprite.speed_scale = lerp(
		$Sprite.speed_scale,
		sprite_speed / (speed / 8),
		acceleration
	)
	
	if Input.is_action_just_pressed("ui_accept"):
		#print("Done!")
		pass

	# Stairs BS
	# if "stair" in get_tile_name():
	# 	if direction.x > 0:
	# 		velocity.x += speed / 2
	# 	elif direction.x < 0:
	# 		velocity.y -= speed / 2

func get_input() -> Vector2:
	var input = Vector2.ZERO

	if not stand_still:
		if Input.is_action_pressed("ui_right"):
			input.x += 1
		if Input.is_action_pressed("ui_left"):
			input.x -= 1
		if Input.is_action_pressed("ui_down"):
			input.y += 1
		if Input.is_action_pressed("ui_up"):
			input.y -= 1
		
	return input

# WARNING: get_facing() gives a LOT of errors! Be careful...

# IDEA: Add Input.is_action_just_released()
func get_facing():
	# Axis
	axis_x = Input.get_axis("ui_left", "ui_right")
	axis_y = Input.get_axis("ui_up", "ui_down")
	
	if axis_x == -1.0:
		$Sprite.play("walk_left")
	elif axis_x == 1.0:
		$Sprite.play("walk_right")
		
	if axis_y == -1.0:
		$Sprite.play("walk_up")
	elif axis_y == 1.0:
		$Sprite.play("walk_down")

# func look_beyond_helper(look_direction, tween: Tween):
# 	tween.tween_property($Camera, "offset", look_direction * look_beyond_power, look_beyond_time)

# func look_beyond(): # Inspired by MGS3 :3
# 	# If a single tween doesn't work,
# 	# bloat with this all the functions below.
# 	tween_look_x = create_tween().set_ease(Tween.EASE_OUT) \
# 		.set_trans(Tween.TRANS_CUBIC)
# 	tween_look_y = create_tween().set_ease(Tween.EASE_OUT) \
# 		.set_trans(Tween.TRANS_CUBIC)

# 	# Left
# 	if Input.is_action_pressed("cg_look_left"): # Pressed
# 		look_beyond_helper(Vector2.LEFT.x, tween_look_x)

# 	if Input.is_action_just_released("cg_look_left"): # Released
# 		look_beyond_helper(Vector2.ZERO, tween_look_x)

# 	# Right
# 	if Input.is_action_pressed("cg_look_right"): # Pressed
# 		look_beyond_helper(Vector2.RIGHT.x, tween_look_x)

# 	if Input.is_action_just_released("cg_look_right"): # Released
# 		look_beyond_helper(Vector2.ZERO, tween_look_x)

# 	# Up
# 	if Input.is_action_pressed("cg_look_up"): # Pressed
# 		look_beyond_helper(Vector2.UP.y, tween_look_y)

# 	if Input.is_action_just_released("cg_look_up"): # Released
# 		look_beyond_helper(Vector2.ZERO.y, tween_look_y)
	
# 	# Down
# 	if Input.is_action_pressed("cg_look_down"): # Pressed
# 		look_beyond_helper(Vector2.DOWN.y, tween_look_y)

# 	if Input.is_action_just_released("cg_look_down"): # Released
# 		look_beyond_helper(Vector2.ZERO.y, tween_look_y)
	
# 	tween_look_x.finished.connect(_if_lookBeyond_finished.bind())
# 	tween_look_y.finished.connect(_if_lookBeyond_finished.bind())

# func _if_lookBeyond_finished():
# 	if tween_look_x and is_instance_valid(tween_look_x):
# 		tween_look_x.kill()

# 	if tween_look_y and is_instance_valid(tween_look_y):
# 		tween_look_y.kill()

# # [v] Ditto as look_beyond() but just pressed a single time
# func look_beyond_once():
# 	tween_look_x = create_tween().set_ease(Tween.EASE_IN_OUT) \
# 		.set_trans(Tween.TRANS_CUBIC)

# 	tween_look_y = create_tween().set_ease(Tween.EASE_IN_OUT) \
# 		.set_trans(Tween.TRANS_CUBIC)

# 	# Left
# 	if Input.is_action_just_pressed("cg_look_left"): # Pressed
# 		look_beyond_helper(Vector2.LEFT.x, tween_look_x)

# 	if Input.is_action_just_released("cg_look_left"): # Released
# 		look_beyond_helper(Vector2.ZERO.x, tween_look_x)

# 	# Right
# 	if Input.is_action_just_pressed("cg_look_right"): # Pressed
# 		look_beyond_helper(Vector2.RIGHT.x, tween_look_x)

# 	if Input.is_action_just_released("cg_look_right"): # Released
# 		look_beyond_helper(Vector2.ZERO.x, tween_look_x)

# 	# Up
# 	if Input.is_action_just_pressed("cg_look_up"): # Pressed
# 		look_beyond_helper(Vector2.UP.y, tween_look_y)

# 	if Input.is_action_just_released("cg_look_up"): # Released
# 		look_beyond_helper(Vector2.ZERO.y, tween_look_y)
	
# 	# Down
# 	if Input.is_action_just_pressed("cg_look_down"): # Pressed
# 		look_beyond_helper(Vector2.DOWN.y, tween_look_y)

# 	if Input.is_action_just_released("cg_look_down"): # Released
# 		look_beyond_helper(Vector2.ZERO.y, tween_look_y)
		
# 	tween_look_x.finished.connect(_if_lookBeyond_finished.bind())
# 	tween_look_y.finished.connect(_if_lookBeyond_finished.bind())

# TODO: Fix this crap.
# EDIT: I give up.
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

# Tilemap
func get_tile_name():
	var search_position = global_position
	var player_offset = Vector2(0, 10)
	search_position += player_offset
	
	var tile_pos = tile_map.local_to_map(search_position)
	var tile_data = tile_map.get_cell_tile_data(tile_pos)

	if tile_data:
		var tile_name = tile_data.get_custom_data("tile_name")
		return tile_name
	else:
		return ""

# Textbox stuff


# Fade
func fade_in():
	stand_still = true
	
	fade_tween = create_tween()
	fade_tween.tween_property($ColorRect, "modulate:a", 1, fade_duration)
	
	$ColorRect/Timer.start(fade_duration)
	await $ColorRect/Timer.timeout
	
	fade_finished.emit()
	stand_still = false
	#print("Done!")
	
func fade_out():
	stand_still = true
	
	fade_tween = create_tween()
	fade_tween.tween_property($ColorRect, "modulate:a", 0, fade_duration)
	
	$ColorRect/Timer.start(fade_duration / 2)
	await $ColorRect/Timer.timeout

	stand_still = false
	$ColorRect/Timer.start(fade_duration / 2)
	await $ColorRect/Timer.timeout
	
	fade_finished.emit()
	#print("Done!")

func npc_start_now():
	$ExampleBalloon/FadeAnim.play("fade_in")
	$ExampleBalloon.start()
