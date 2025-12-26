extends Node2D

@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")
@onready var _load = get_node("/root/auto_load")

func _ready() -> void:
  _fade._out.emit()
  RenderingServer.set_default_clear_color(Color.BLACK)
  
  $bgm.volume_db = 5

  $spr_logo.modulate = Color($spr_logo.modulate, 0)
  $spr_logo.position = _sgt.window_size / 2

  $cont_ratio.size = _sgt.window_size

  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property($spr_logo, "modulate",
    Color($spr_logo.modulate, 1), 0.5)
  
  $bgm.play(0)
  await get_tree().create_timer(1.0).timeout
  create_tween().tween_property($bgm, 'volume_db', -50, _sgt.fade_time * 26)
  
  _fade._in.emit()

  #await get_tree().create_timer(_sgt.fade_time * 2).timeout

  _load.changeScene("res://assets/scenes/scn_Title0/scn_Title0.tscn")
