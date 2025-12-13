extends Control


@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")


func _ready() -> void:
  RenderingServer.set_default_clear_color(Color.BLACK)
  
  $rich_text_label.size = _sgt.window_size
  $label_buttonprompt.size = _sgt.window_size
  
  $audio_stream_player.volume_db = -20
  create_tween().tween_property($audio_stream_player, 'volume_db', 0, 0.5)
