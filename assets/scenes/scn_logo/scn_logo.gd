extends Node2D

@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")

func _ready() -> void:
  _fade._out.emit()
  RenderingServer.set_default_clear_color(Color.BLACK)

  $spr_logo.modulate = Color($spr_logo.modulate, 0)
  $spr_logo.position = _sgt.window_size / 2

  $cont_ratio.size = _sgt.window_size

  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property($spr_logo, "modulate",
    Color($spr_logo.modulate, 1), 0.5)
  
  $bgm.play()
  await get_tree().create_timer(1.1).timeout
  
  _fade._in.emit()

  await get_tree().create_timer(_sgt.setting_fadeTime).timeout

  get_tree().change_scene_to_file("res://assets/scenes/scn_mainMenu/scn_mainMenu.tscn")
