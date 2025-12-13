extends Control


@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')


func _ready() -> void:
  $cont_margin/ratio.size = _sgt.window_size
  
func _process(delta: float) -> void:
  pass
