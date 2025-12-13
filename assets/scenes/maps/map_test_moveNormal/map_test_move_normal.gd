extends Node2D

@onready var auto_fade = get_node('/root/auto_fade')

func _ready() -> void:
  auto_fade._out.emit()
