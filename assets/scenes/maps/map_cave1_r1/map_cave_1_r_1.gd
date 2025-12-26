extends Node2D

@onready var _fade = get_node('/root/auto_fade')

func _ready():
  RenderingServer.set_default_clear_color(Color.BLACK)

  _fade._out.emit()
