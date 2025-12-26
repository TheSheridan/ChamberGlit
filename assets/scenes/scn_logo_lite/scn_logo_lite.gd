extends Node2D

## False: Dark; True: Light
@export_enum("Dark", "Light") var theme: int = 1

@onready var spr_light = preload('res://assets/images/logo_arWhite.png')
@onready var spr_dark  = preload('res://assets/images/logo_arBlack.png')

@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')

var fade_time = 0.5

var bgColor: Color = Color.BLACK

func _ready() -> void:
  _fade._out.emit()
  
  $cont.size = _sgt.window_size
  
  $cont/spr.modulate = Color($cont/spr.modulate, 0)
  $cont/spr.offset = ($cont.size / 2) / $cont/spr.scale
  
  $cont/spr.scale = Vector2(32, 32)
  
  $bg.texture.width = _sgt.window_size.x
  $bg.texture.height = _sgt.window_size.y
  
  $txt.custom_minimum_size = _sgt.window_size - Vector2(0, 0)
  print($cont/spr.offset.y / ($cont/spr.scale.y / 2))
  $txt.position = Vector2(0, _sgt.window_size.y - $txt.custom_minimum_size.y)

  $bgs.play()

  match theme:
    0:
      $cont/spr.texture = spr_light
      $txt.text = "[color=WHITE]" + $txt.text
            #RenderingServer.set_default_clear_color(Color.BLACK)
      create_tween().tween_property(self, "bgColor", Color.BLACK,
        fade_time)
    1:
      $txt.text = "[color=BLACK]" + $txt.text
      $cont/spr.texture = spr_dark
      create_tween().tween_property(self, "bgColor", Color.WHITE,
        fade_time)
        # _:
        #     var rng = RandomNumberGenerator.new()
        #     rng.randf_range(0,1)

        #     if rng == 0: theme = false
        #     else:        theme = true

  create_tween().tween_property(
    $cont/spr,
    "modulate",
    Color($cont/spr.modulate, 1),
    fade_time)
    
  create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)\
  .tween_property(
    $cont/spr,
    "scale",
    Vector2(16, 16),
    fade_time)
  
  anim_noise(0)
  
  var timer = get_tree().create_timer(1.5)
  await timer.timeout
  
  anim_noise(1)
  
  create_tween().tween_property(
    $cont/spr,
    "modulate",
    Color($cont/spr.modulate, 0),
    fade_time)
    
  create_tween().tween_property(self, "bgColor", Color.BLACK,
    fade_time)
  
  create_tween().tween_property(
    $bg,
    "modulate",
    Color($bg.modulate, 0),
    fade_time)
  
  var timer2 = get_tree().create_timer(fade_time)
  await timer2.timeout
  
  _load.changeScene("res://assets/scenes/scn_mainMenu/scn_mainMenu.tscn")

func _process(_delta: float) -> void:
  RenderingServer.set_default_clear_color(bgColor)
  
func anim_noise(state: int) -> void:
  match state:
    0:
      create_tween().set_ease(Tween.EASE_IN_OUT)\
      .set_trans(Tween.TRANS_CUBIC)\
      .tween_property(
        $bg, "texture:noise"\
        + ":fractal_weighted_strength",
        0.5, 1
      )
  
    1:
      create_tween().set_ease(Tween.EASE_IN_OUT)\
      .set_trans(Tween.TRANS_CUBIC)\
      .tween_property(
        $bg, "texture:noise"\
        + ":fractal_weighted_strength",
        1, 0.5
      )
