# Refactored!
## Same script as chr_bell.gd but friction is disabled.
extends CharacterBody2D


var axis_x_temp: float
var axis_y_temp: float

var position_previous: Vector2

## Sets the _camera_ zoom (default 1).
@export var camera_zoom = 1.0
var is_camera_zoom_on = true

@export var camera_lerp_duration: float = 0.3
@export var camera_magnitude: float = 3
var get_input_temp_position: Vector2 = Vector2(0, 0)

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
## Friction strength.
@export_range(0.0, 1.0) var friction = 0.8
## Acceleration strength.
@export_range(0.0, 1.0) var acceleration = 0.8

var speed: float = initial_speed
var directed_velocity: float

var camera_weight: float = 0.0

var tween1: Tween
var tween2: Tween

var tween_a: Tween
var tween_b: Tween

@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')


# Resources
@onready var text = $Control/Margin/Text


# Main
func _ready():
	# Default animation
	$Sprite.animation = "idle_down"
	$Sprite.play()
	
	speed = initial_speed

func _process(_delta) -> void:
	#PromptManager
	$Control.size = _sgt.window_size
	$Control/Margin.size = $Control.size
	$Control.position = -_sgt.window_size / 2
	text.text = "Hi."

	if is_camera_zoom_on:
		$Camera.zoom = Vector2(camera_zoom, camera_zoom)

	# getInput()
	if getInput().x == 0:
		directed_velocity = (velocity.y * getInput().y)

	if getInput().y == 0:
		directed_velocity = (velocity.x * getInput().x)
	
	# looked_beyond
	if Input.is_action_just_pressed("ui_select"):
		match looked_beyond_once:
			false: looked_beyond_once = true
			true: looked_beyond_once = false

	match looked_beyond_once:
		false: lookBeyond()
		true: lookBeyondOnce()
		_: pass
	
	# getFacing()
	if $Ray.target_position.x != 0:
		axis_x_temp = $Ray.target_position.x
	if $Ray.target_position.y != 0:
		axis_y_temp = $Ray.target_position.y
		
	if Input.is_action_pressed('cg_cancel'):
		speed = sprite_int_speed
	if Input.is_action_just_released('cg_cancel'):
		speed = initial_speed
	
	if getInput() != Vector2.ZERO:
		lerp_camera_left()
	else:
		lerp_camera_right()	

	get_input_temp_position = getInput()
	position_previous = position

func _physics_process(delta) -> void:
	getFacing()

	$Camera.offset = lerp($Camera.offset, velocity / 16, 0.5)
	$Camera.position = lerp($Camera.position, getInput() * camera_magnitude, camera_weight)

	# Handle acceleration
	position += (getInput() * speed) * delta
	
	move_and_slide()

	# Animation speed
	$Sprite.speed_scale = lerp(
		$Sprite.speed_scale,
		directed_velocity / (speed / 8),
		acceleration
	)

func getInput():
	var input = Vector2()

	if Input.is_action_pressed("ui_right"):
		input.x += 1
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_down"):
		input.y += 1
	if Input.is_action_pressed("ui_up"):
		input.y -= 1

	return input

# IDEA: Add Input.is_action_just_released()
func getFacing():
	if Input.is_action_just_pressed("ui_left"):
		$Sprite.play("walk_left")

	if Input.is_action_just_pressed("ui_right"):
		$Sprite.play("walk_right")

	if Input.is_action_just_pressed("ui_up"):
		$Sprite.play("walk_up")

	if Input.is_action_just_pressed("ui_down"):
		$Sprite.play("walk_down")
	
	# Axis
	var axis_x: float = Input.get_axis("ui_left", "ui_right")
	var axis_y: float = Input.get_axis("ui_up", "ui_down")

	# Up/Down
	if Input.is_action_pressed("ui_left") \
	or Input.is_action_pressed("ui_right"):
		$Ray.target_position.x = axis_x * ray_size

	if Input.is_action_just_released("ui_left") \
	or Input.is_action_just_released("ui_right"):
		$Ray.target_position.x = axis_x_temp

	if Input.is_action_pressed("ui_up") \
	or Input.is_action_pressed("ui_down"):
		$Ray.target_position.y = axis_y * ray_size

	if Input.is_action_just_released("ui_up") \
	or Input.is_action_just_released("ui_down"):
		$Ray.target_position.y = axis_y_temp

func lookBeyond(): # Inspired by MGS3 :3
	# If a single tween doesn't work,
	# bloat with this all the functions below.
	tween_a = create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	tween_b = create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	# Left
	if Input.is_action_pressed("cg_look_left"): # Pressed
		tween_a.tween_property($Camera, "offset:x",
			Vector2.LEFT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_left"): # Released
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Right
	if Input.is_action_pressed("cg_look_right"): # Pressed
		tween_a.tween_property($Camera, "offset:x",
			Vector2.RIGHT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_right"): # Released
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Up
	if Input.is_action_pressed("cg_look_up"): # Pressed
		tween_b.tween_property($Camera, "offset:y",
			Vector2.UP.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_up"): # Released
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)
	
	# Down
	if Input.is_action_pressed("cg_look_down"): # Pressed
		tween_b.tween_property($Camera, "offset:y",
			Vector2.DOWN.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_down"): # Released
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)
	
	tween_a.finished.connect(_if_lookBeyond_finished.bind())
	tween_b.finished.connect(_if_lookBeyond_finished.bind())

func _if_lookBeyond_finished():
	if tween_a and is_instance_valid(tween_a):
		tween_a.kill()

	if tween_b and is_instance_valid(tween_b):
		tween_b.kill()

# [v] Ditto as lookBeyond() but just pressed a single time
func lookBeyondOnce():
	tween_a = create_tween().set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	tween_b = create_tween().set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	# Left
	if Input.is_action_just_pressed("cg_look_left"): # Pressed
		tween_a.tween_property($Camera, "offset:x", Vector2.LEFT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_left"): # Released
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Right
	if Input.is_action_just_pressed("cg_look_right"): # Pressed
		tween_a.tween_property($Camera, "offset:x", Vector2.RIGHT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_right"): # Released
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Up
	if Input.is_action_just_pressed("cg_look_up"): # Pressed
		tween_b.tween_property($Camera, "offset:y", Vector2.UP.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_up"): # Released
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)
	
	# Down
	if Input.is_action_just_pressed("cg_look_down"): # Pressed
		tween_b.tween_property($Camera, "offset:y", Vector2.DOWN.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_down"): # Released
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)
		
	tween_a.finished.connect(_if_lookBeyond_finished.bind())
	tween_b.finished.connect(_if_lookBeyond_finished.bind())

# TODO: Fix this crap.
func lerp_camera_left():
	if not tween1 and is_instance_valid(tween1):
		tween1.kill()
	
	tween1 = create_tween()
	tween1.set_ease(Tween.EASE_IN)
	tween1.set_trans(Tween.TRANS_CUBIC)

	tween1.tween_property(self, 'camera_weight', 1.0, camera_lerp_duration)

	tween1.finished.connect(_on_tween1_finished.bind(), CONNECT_ONE_SHOT)

func _on_tween1_finished():
	if tween1 and tween1.is_connected("finished", _on_tween1_finished.bind()):
		tween1.finished.disconnect(_on_tween1_finished)

func lerp_camera_right():
	if not tween2 and is_instance_valid(tween2):
		tween2.kill()
  
	tween2 = create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_CUBIC)

	tween2.tween_property(self, 'camera_weight', 0.0, camera_lerp_duration)

	tween2.finished.connect(_on_tween2_finished.bind(), CONNECT_ONE_SHOT)
  
func _on_tween2_finished():
	if tween2 and tween2.is_connected("finished", _on_tween2_finished.bind()):
		tween2.finished.disconnect(_on_tween2_finished)
