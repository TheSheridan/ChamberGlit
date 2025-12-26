## Same script as chr_bell.gd but friction is disabled.
extends CharacterBody2D

# Variables

# Used in getFacing()
var axis_x_temp: float
var axis_y_temp: float

var position_previous: Vector2

@export var camZoom = 1.0 ## Sets the camera zoom (default 1).
var camZoom_on = true

@export var cam_lerpDuration: float = 0.3
@export var cam_magnitude: float = 3
var getInput_temp: Vector2 = Vector2(0, 0)

@export var raySize = 50 ## Sets how large is the raycast.
@export var rayStrength = 0.5 ## Strength of the raycast movement.

@export var lookBeyond_mult = 200 ## Sets how much the camera pans when looking to sides.
@export var lookBeyond_time = 0.3 ## Time taken while looking to sides.
@export var lookBeyondOnce_check: bool = false ## Checks if looking to sides takes a single press.

@export var initialSpeed: float = 600 ## Initial movement speed.
@export var sprintSpeed: float = 1000 ## Sprint movement speed.
@export_range(0.0, 1.0) var friction = 0.8 ## Friction strength.
@export_range(0.0, 1.0) var acceleration = 0.8 ## Acceleration strength.

var speed: float = initialSpeed
var velDirected: float

var cam_weight: float = 0.0

var tween1: Tween
var tween2: Tween


# Resources
@onready var col = $col
@onready var spr = $spr
@onready var cam = $cam
@onready var ray = $ray


# Main
func _get_ready():
    spr.animation = "idle_down" # Default animation
    spr.play()
    
    speed = initialSpeed

    tween1 = create_tween()
    tween2 = create_tween()
    

func _process(_delta) -> void:
    #PromptManager

    if camZoom_on:
        cam.zoom = Vector2(camZoom, camZoom)

    if getInput().x == 0:
        velDirected = (velocity.y * getInput().y)
    if getInput().y == 0:
        velDirected = (velocity.x * getInput().x)
    
    if Input.is_action_just_pressed("ui_select"):
        match lookBeyondOnce_check:
            false: lookBeyondOnce_check = true
            true: lookBeyondOnce_check = false
    match lookBeyondOnce_check:
        false: lookBeyond()
        true: lookBeyondOnce()
        _: pass
    
    # getFacing()
    if ray.target_position.x != 0:
        axis_x_temp = ray.target_position.x
    if ray.target_position.y != 0:
        axis_y_temp = ray.target_position.y
        
    if Input.is_action_pressed('cg_cancel'):
      speed = sprintSpeed
    if Input.is_action_just_released('cg_cancel'):
      speed = initialSpeed

    #print("axis_x_temp: " + str(axis_x_temp) + ", axis_y_temp: " + str(axis_y_temp))
    
    #tweens
    
    if getInput() != Vector2.ZERO:
      lerpCamera_left()
      #cam_weight = lerp(cam_weight, 1.0, cam_lerpDuration)
      #tween1.tween_property(self, 'cam_weight', 1.0, cam_lerpDuration)
    else:
      lerpCamera_right()
      #cam_weight = lerp(cam_weight, 0.0, cam_lerpDuration)
      #tween2.tween_property(self, 'cam_weight', 0.0, cam_lerpDuration)
    
    getInput_temp = getInput()
    
    position_previous = position

func _physics_process(delta) -> void:
    getFacing()
    cam.offset = lerp(cam.offset, velocity / 16, 0.5)
    
    #print("cam_weight = " + str(cam_weight) + "\nget_input() = " + str(getInput()))
      
    cam.position = lerp(cam.position, getInput() * cam_magnitude, cam_weight)

    # Handle acceleratio
    position += (getInput() * speed) * delta
    
    move_and_slide()
    
    #print(speed)

    # Animation speed
    spr.speed_scale = lerp(
        spr.speed_scale,
        velDirected / (speed / 8),
        acceleration
    )


func getInput():
    var input = Vector2()

    if Input.is_action_pressed("ui_right"): input.x += 1
    if Input.is_action_pressed("ui_left"): input.x -= 1
    if Input.is_action_pressed("ui_down"): input.y += 1
    if Input.is_action_pressed("ui_up"): input.y -= 1

    return input

func getFacing():
    # TODO: Test if a match pattern can work here :/

    # Sprite stuff
    if Input.is_action_just_pressed("ui_left"):
        spr.play("walk_left")
    #if Input.is_action_just_released("ui_left"):

    if Input.is_action_just_pressed("ui_right"):
        spr.play("walk_right")

    if Input.is_action_just_pressed("ui_up"):
        spr.play("walk_up")

    if Input.is_action_just_pressed("ui_down"):
        spr.play("walk_down")
    
    # Axis
    var axis_x: float = Input.get_axis("ui_left", "ui_right")
    var axis_y: float = Input.get_axis("ui_up", "ui_down")

        # Up/Down
    if Input.is_action_pressed("ui_left") \
    or Input.is_action_pressed("ui_right"):
        ray.target_position.x = lerp(
            ray.target_position.x,
            axis_x * raySize,
            rayStrength
        )
    if Input.is_action_just_released("ui_left") \
    or Input.is_action_just_released("ui_right"):
        ray.target_position.x = lerp(
            ray.target_position.x,
            axis_x_temp,
            rayStrength
        )
        # Left/Right
    if Input.is_action_pressed("ui_up") \
    or Input.is_action_pressed("ui_down"):
        ray.target_position.y = lerp(
            ray.target_position.y,
            axis_y * raySize,
            rayStrength
        )
    if Input.is_action_just_released("ui_up") \
    or Input.is_action_just_released("ui_down"):
        ray.target_position.y = lerp(
            ray.target_position.y,
            axis_y_temp,
            rayStrength
        )


func lookBeyond(): # Inspired by MGS3 :3
    # If a single tween doesn't work,
    # bloat with this all the functions below.
    var tw_x = create_tween().set_ease(Tween.EASE_OUT) \
        .set_trans(Tween.TRANS_CUBIC)
    var tw_y = create_tween().set_ease(Tween.EASE_OUT) \
        .set_trans(Tween.TRANS_CUBIC)

    # Left
    if Input.is_action_pressed("cg_look_left"): # Pressed
        tw_x.tween_property(cam, "offset:x",
            Vector2.LEFT.x * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_left"): # Released
        tw_x.tween_property(cam, "offset:x", Vector2.ZERO.x, lookBeyond_time)

    # Right
    if Input.is_action_pressed("cg_look_right"): # Pressed
        tw_x.tween_property(cam, "offset:x",
            Vector2.RIGHT.x * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_right"): # Released
        tw_x.tween_property(cam, "offset:x", Vector2.ZERO.x, lookBeyond_time)

    # Up
    if Input.is_action_pressed("cg_look_up"): # Pressed
        tw_y.tween_property(cam, "offset:y",
            Vector2.UP.y * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_up"): # Released
        tw_y.tween_property(cam, "offset:y", Vector2.ZERO.y, lookBeyond_time)
    
    # Down
    if Input.is_action_pressed("cg_look_down"): # Pressed
        tw_y.tween_property(cam, "offset:y",
            Vector2.DOWN.y * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_down"): # Released
        tw_y.tween_property(cam, "offset:y", Vector2.ZERO.y, lookBeyond_time)
        
    tw_x.kill()
    tw_y.kill()

# [v] Ditto as lookBeyond() but just pressed a single time
func lookBeyondOnce():
    var tw_x = create_tween().set_ease(Tween.EASE_OUT) \
        .set_trans(Tween.TRANS_CUBIC)
    var tw_y = create_tween().set_ease(Tween.EASE_OUT) \
        .set_trans(Tween.TRANS_CUBIC)

    # Left
    if Input.is_action_just_pressed("cg_look_left"): # Pressed
        tw_x.tween_property(cam, "offset:x",
            Vector2.LEFT.x * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_left"): # Released
        tw_x.tween_property(cam, "offset:x", Vector2.ZERO.x, lookBeyond_time)

    # Right
    if Input.is_action_just_pressed("cg_look_right"): # Pressed
        tw_x.tween_property(cam, "offset:x",
            Vector2.RIGHT.x * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_right"): # Released
        tw_x.tween_property(cam, "offset:x", Vector2.ZERO.x, lookBeyond_time)

    # Up
    if Input.is_action_just_pressed("cg_look_up"): # Pressed
        tw_y.tween_property(cam, "offset:y",
            Vector2.UP.y * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_up"): # Released
        tw_y.tween_property(cam, "offset:y", Vector2.ZERO.y, lookBeyond_time)
    
    # Down
    if Input.is_action_just_pressed("cg_look_down"): # Pressed
        tw_y.tween_property(cam, "offset:y",
            Vector2.DOWN.y * lookBeyond_mult, lookBeyond_time)
    if Input.is_action_just_released("cg_look_down"): # Released
        tw_y.tween_property(cam, "offset:y", Vector2.ZERO.y, lookBeyond_time)
        
    tw_x.kill()
    tw_y.kill()

#func changeZoom(
    #zoom: float,
    #time: float,
    #tween_ease: Tween.EaseType,
    #tween_trans: Tween.TransitionType):
#
    #camZoom_on = false
#
    #var tw = create_tween().set_ease(tween_ease).set_trans(tween_trans) \
    #.tween_property(cam, "zoom", Vector2(zoom, zoom), time)
#
    #await tw.finished
    #camZoom = zoom
    #camZoom_on = true
    #tw.kill()

func lerpCamera_left():
  if not tween1 and is_instance_valid(tween1):
    tween1.kill()
    
  tween1 = create_tween()
  tween1.set_ease(Tween.EASE_IN)
  tween1.set_trans(Tween.TRANS_CUBIC)
  
  tween1.tween_property(self, 'cam_weight', 1.0, cam_lerpDuration)
  
  tween1.finished.connect(_on_tween1_finished.bind(), CONNECT_ONE_SHOT)
  
func _on_tween1_finished():
  if tween1 and tween1.is_connected("finished", _on_tween1_finished.bind()):
    tween1.finished.disconnect(_on_tween1_finished)


func lerpCamera_right():
  if not tween2 and is_instance_valid(tween2):
    tween2.kill()
  
  tween2 = create_tween()
  tween2.set_ease(Tween.EASE_OUT)
  tween2.set_trans(Tween.TRANS_CUBIC)

  tween2.tween_property(self, 'cam_weight', 0.0, cam_lerpDuration)
  
  tween2.finished.connect(_on_tween2_finished.bind(), CONNECT_ONE_SHOT)
  
func _on_tween2_finished():
  if tween2 and tween2.is_connected("finished", _on_tween2_finished.bind()):
    tween2.finished.disconnect(_on_tween2_finished)
