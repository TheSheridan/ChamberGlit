extends Node2D

@onready var _fade = get_node('/root/auto_fade')
@onready var _sgt = get_node('/root/auto_singleton')

func _ready():
  RenderingServer.set_default_clear_color(Color.DARK_GRAY)
  _fade._out.emit()
  $color_rect.size = _sgt.window_size + (_sgt.window_size / 4)
