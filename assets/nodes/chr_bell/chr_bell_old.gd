extends CharacterBody2D


var speed: float
var directed_velocity: float

# get_facing()
var axis_x_temp: float
var axis_y_temp: float

@export var cam_zoom = 0.8 ## Sets the $Cameraera zoom (default 1).
var is_cam_zoom_on: bool = true

@export var ray_size = 50 ## Sets how large is the $Raycast.
@export var ray_strength = 0.5 ## Strength of the $Raycast movement.

@export var look_beyond_power = 200 ## Sets how much the $Cameraera pans when looking to sides.
@export var look_beyond_time = 0.3 ## Time taken while looking to sides.
@export var looked_beyond_once: bool = false ## Checks if looking to sides takes a single press.

@export var initial_speed = 600 ## Initial movement speed.
@export var sprint_speed = 1000 ## sprint movement speed.
@export_range(0.0, 1.0) var friction = 0.2 ## Friction strength.
@export_range(0.0, 1.0) var acceleration = 0.1 ## Acceleration strength.


func _get_ready():
	#Default animation
	$Sprite.animation = "idle_down"
	$Sprite.play()
	

func _process(_delta) -> void:
	if is_cam_zoom_on:
		$Camera.zoom = Vector2(cam_zoom, cam_zoom)

	if get_input().x == 0:
		directed_velocity = (velocity.y * get_input().y)
	if get_input().y == 0:
		directed_velocity = (velocity.x * get_input().x)
	
	if Input.is_action_just_pressed("ui_select"):
		match looked_beyond_once:
			false: looked_beyond_once = true
			true: looked_beyond_once = false

	match looked_beyond_once:
		false: look_beyond()
		true: look_beyond_once()
		_: pass
	
	# get_facing()
	if $Ray.target_position.x != 0:
		axis_x_temp = $Ray.target_position.x
	if $Ray.target_position.y != 0:
		axis_y_temp = $Ray.target_position.y

	#print("axis_x_temp: " + str(axis_x_temp) + ", axis_y_temp: " + str(axis_y_temp))
	
	if Input.is_action_pressed('ui_cancel'):
		speed = sprint_speed
	if Input.is_action_just_released('ui_cancel'):
		speed = initial_speed


func _physics_process(_delta):
	get_facing()
	$Camera.offset = lerp($Camera.offset, velocity / 64, 0.1)

	# sprint
	if Input.is_action_pressed("ui_cancel"):
		speed = sprint_speed
	else:
		speed = initial_speed

	# Handle acceleration
	var direction = get_input()
	if direction.length() > 0:
		velocity = lerp(
			velocity,
			direction.normalized() * speed,
			acceleration
		)
	else:
		velocity = lerp(
			velocity,
			Vector2.ZERO,
			friction
		)
	move_and_slide()

	# Animation speed
	$Sprite.speed_scale = lerp(
		$Sprite.speed_scale,
		directed_velocity / (speed / 8),
		acceleration
	)


func get_input():
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

func get_facing():
	if Input.is_action_just_pressed("ui_left"):
		$Sprite.play("walk_left")

	if Input.is_action_just_pressed("ui_right"):
		$Sprite.play("walk_right")

	if Input.is_action_just_pressed("ui_up"):
		$Sprite.play("walk_up")

	if Input.is_action_just_pressed("ui_down"):
		$Sprite.play("walk_down")
	
	# Axis
	var axis_x = Input.get_axis("ui_left", "ui_right")
	var axis_y = Input.get_axis("ui_up", "ui_down")

	# Up/Down
	if Input.is_action_pressed("ui_left") \
	or Input.is_action_pressed("ui_right"):
		$Ray.target_position.x = lerp(
			$Ray.target_position.x,
			axis_x * ray_size,
			ray_strength
		)

	if Input.is_action_just_released("ui_left") \
	or Input.is_action_just_released("ui_right"):
		$Ray.target_position.x = lerp(
			$Ray.target_position.x,
			axis_x_temp,
			ray_strength
		)

	# Left/Right
	if Input.is_action_pressed("ui_up") \
	or Input.is_action_pressed("ui_down"):
		$Ray.target_position.y = lerp(
			$Ray.target_position.y,
			axis_y * ray_size,
			ray_strength
		)

	if Input.is_action_just_released("ui_up") \
	or Input.is_action_just_released("ui_down"):
		$Ray.target_position.y = lerp(
			$Ray.target_position.y,
			axis_y_temp,
			ray_strength
		)


func look_beyond():
	var tween_a = create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	var tween_b = create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	# Left
	if Input.is_action_pressed("cg_look_left"):  
		tween_a.tween_property($Camera, "offset:x", Vector2.LEFT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_left"):
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Right
	if Input.is_action_pressed("cg_look_right"):  
		tween_a.tween_property($Camera, "offset:x", Vector2.RIGHT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_right"):
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Up
	if Input.is_action_pressed("cg_look_up"):  
		tween_b.tween_property($Camera, "offset:y", Vector2.UP.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_up"):
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)
	
	# Down
	if Input.is_action_pressed("cg_look_down"):  
		tween_b.tween_property($Camera, "offset:y", Vector2.DOWN.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_down"):
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)


# TODO: Find a way to get rid of this crap.
func look_beyond_once():
	var tween_a = create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	var tween_b = create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

	# Left
	if Input.is_action_just_pressed("cg_look_left"):  
		tween_a.tween_property($Camera, "offset:x", Vector2.LEFT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_left"):
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Right
	if Input.is_action_just_pressed("cg_look_right"):  
		tween_a.tween_property($Camera, "offset:x", Vector2.RIGHT.x * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_right"):
		tween_a.tween_property($Camera, "offset:x", Vector2.ZERO.x, look_beyond_time)

	# Up
	if Input.is_action_just_pressed("cg_look_up"):  
		tween_b.tween_property($Camera, "offset:y", Vector2.UP.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_up"):
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)
	
	# Down
	if Input.is_action_just_pressed("cg_look_down"):  
		tween_b.tween_property($Camera, "offset:y", Vector2.DOWN.y * look_beyond_power, look_beyond_time)

	if Input.is_action_just_released("cg_look_down"):
		tween_b.tween_property($Camera, "offset:y", Vector2.ZERO.y, look_beyond_time)

func change_zoom(
	zoom: float,
	time: float,
	tween_ease: Tween.EaseType,
	tween_trans: Tween.TransitionType):

	is_cam_zoom_on = false

	var tw = create_tween().set_ease(tween_ease) \
			.set_trans(tween_trans) \
			.tween_property($Camera, "zoom", Vector2(zoom, zoom), time)

	await tw.finished
	cam_zoom = zoom
	is_cam_zoom_on = true
