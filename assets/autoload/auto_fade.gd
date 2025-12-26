extends Control

# Variables
var is_debug: bool = false

var is_on: bool = true
var color = color_enum.DARK
signal _in
signal _out

var fade_time = 0.25

@export var index = 10

enum color_enum {LIGHT, DARK}

# Resources
@onready var _stg = get_node("/root/auto_singleton")

func _ready() -> void:
  $bg.z_index = index
  # [v] TODO: Modify this if stuff happens with the camera
  $bg.size = _stg.window_size * 2
  pivot_offset = _stg.window_size * 2
  
  connect("_in", anim_fadeIn.bind())
  connect("_out", anim_fadeOut.bind())
  
func _process(_delta: float) -> void:
  if !is_debug:
    if is_on:
      $bg.show()
    else:
      $bg.hide()
  
  else:
    hide()

  match color:
    color_enum.LIGHT:
      $bg.color = Color(1, 1, 1)
    color_enum.DARK:
      $bg.color = Color(0, 0, 0)
  
  #print($bg.color)
  #print("bg z_index is " + str($bg.z_index))

  $n_animLoading.position = _stg.window_size - Vector2(80, 80)

func anim_fadeIn():
  $n_animLoading.fade_in.emit()

  $bg.z_index = -index

  is_on = true
  $bg.color = Color($bg.color, 0)
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property($bg, "color", Color($bg.color, 1), _stg.setting_fadeTime)

  $bg.z_index = index
  
func anim_fadeOut():
  $n_animLoading.fade_out.emit()

  $bg.z_index = index

  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property($bg, "color", Color($bg.color, 0), _stg.setting_fadeTime)
  is_on = false

  $bg.z_index = -index
