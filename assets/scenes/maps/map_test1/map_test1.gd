extends Node2D

# Resources
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
# Variables

# Main
func _ready() -> void:
  _fade._out.emit()
