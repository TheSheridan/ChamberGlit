extends CharacterBody2D

var is_diagonal: bool = false
var previous_ray_pos: Vector2

func _ready() -> void:
  $rayCast2d.target_position = Vector2.RIGHT

func _process(delta: float) -> void:
  var input: Vector2 = get_input()
  var tween_time = 0.5
  
  # Print
  #print_rich("-=-\nRaycast pos: " + str($rayCast2d.target_position) \
    #+ "\nPrevious ray pos: " + str(previous_ray_pos) \
    #+ "\nSprite rotation: " + str($sprite2d.rotation_degrees) \
    #+ "\n-=-\n")

  # Raycast stuff
  if input != Vector2.ZERO:  
    $rayCast2d.target_position = \
    #lerp($rayCast2d.target_position, input * 50, 0.5)
    input * 50
  
  if $rayCast2d.target_position != Vector2.ZERO:
    previous_ray_pos = $rayCast2d.target_position
    
  # Rotate sprite
  if previous_ray_pos == Vector2.LEFT * 50:
    rotate_sprite((PI * 3) / 2, 0.5)
  if previous_ray_pos == Vector2.RIGHT * 50:
    rotate_sprite(PI / 2, 0.5)
    
  if previous_ray_pos == Vector2.UP * 50:
    rotate_sprite(0, 0.5)
  if previous_ray_pos == Vector2.DOWN * 50:
    rotate_sprite(PI, 0.5)
    
  #if $sprite2d.rotation_degrees == 360:
    #$sprite2d.rotation_degrees = 0
    
  # \_ Diagonals...
  #if previous_ray_pos == Vector2(-1, -1) * 50:
    #rotate_sprite(315.0, 0.5)
  #if previous_ray_pos == Vector2(-1, 1) * 50:
    #rotate_sprite(225.0, 0.5)
  #if previous_ray_pos == Vector2(1, 1) * 50:
    #rotate_sprite(135.0, 0.5)
  #if previous_ray_pos == Vector2(1, -1) * 50:
    #rotate_sprite(45.0, 0.5)
    
  position += input * 2
  
func get_input():
  var input: Vector2 = Vector2()
  
  if Input.is_action_pressed('ui_up'):    input.y -= 1
  if Input.is_action_pressed('ui_down'):  input.y += 1
  if Input.is_action_pressed('ui_left'):  input.x -= 1
  if Input.is_action_pressed('ui_right'): input.x += 1
  
  return input

func rotate_sprite(rotate: float, weight: float) -> void:
  $sprite2d.rotation = lerp($sprite2d.rotation, rotate, weight)
