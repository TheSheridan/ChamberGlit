extends Node2D


@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")
@onready var _load = get_node("/root/auto_load")


func _ready() -> void:
  _fade._out.emit()
  
  
func _process(_delta) -> void:
  _fade.position = $chr_bell.position - (_sgt.window_size / 2) \
  - Vector2(80, 60)
  
  #print("\n"
    #+ "===========================================\n"
    #+ "Fade position: " + str(_fade.position) + '\n'
    #+ "MC position: " + str($chr_bell.position) + '\n'
    #+ "===========================================\n"
    #+ "\n\n"
  #)

func fade_in():
  var tween = create_tween()
  tween.tween_property(self, 'modulate', Color(modulate, 1))
