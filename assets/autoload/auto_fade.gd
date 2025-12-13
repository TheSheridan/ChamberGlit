extends Control

# Variables
var is_debug: bool = true

var is_on: bool = true
var color = color_enum.DARK
signal _in
signal _out

enum color_enum {LIGHT, DARK}

# Resources
@onready var _stg = get_node("/root/auto_singleton")

func _ready() -> void:
  $bg.z_index = 5
  # [v] TODO: Modify this if stuff happens with the camera
  $bg.size = _stg.window_size * 2
  pivot_offset = _stg.window_size * 2
  
  connect("_in", Callable(self, "anim_fadeIn"))
  connect("_out", Callable(self, "anim_fadeOut"))
  
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

func anim_fadeIn():
  $bg.z_index = -5

  is_on = true
  $bg.color = Color($bg.color, 0)
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property($bg, "color", Color($bg.color, 1), _stg.setting_fadeTime)

  $bg.z_index = 5
  
func anim_fadeOut():
  $bg.z_index = 5

  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property($bg, "color", Color($bg.color, 0), _stg.setting_fadeTime)
  is_on = false

  $bg.z_index = -5
