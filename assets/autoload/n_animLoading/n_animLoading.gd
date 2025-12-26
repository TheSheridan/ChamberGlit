extends Control

@export_enum("Night", "Light") var spriteColor: int = 1
@export_enum("Night", "Light") var bgColor:     int = 0

var sprite_night = load("res://assets/images/loading.png")
var sprite_light = load("res://assets/images/loading_white.png")

@export var customPosition: bool = false
#@export var customPosition_bg: bool = false

@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')

signal fade_in
signal fade_out

func _ready() -> void:
  modulate = Color(modulate, 0)
  
  fade_in.connect(anim_fadeIn.bind())
  fade_out.connect(anim_fadeOut.bind())


func _process(_delta: float) -> void:
  match spriteColor:
    0: $cont/spr.texture = sprite_night
    1: $cont/spr.texture = sprite_light
    
  match bgColor:
    0: $bg.color = Color.BLACK
    1: $bg.color = Color.WHITE

  $cont/spr.offset = $cont.size / 2
  $cont/spr.rotation_degrees += 1
    
  $bg.size = _sgt.window_size
    
  if customPosition == false:
    $cont/spr.position = _sgt.window_size \
   - ($cont/spr.texture.get_size() * 2)
  else: pass


func anim_fadeIn():
  create_tween().tween_property(
    self, "modulate",
    Color(modulate, 1),
    _sgt.fade_time
  )

func anim_fadeOut():
    create_tween().tween_property(
        self, "modulate",
        Color(modulate, 0),
        _sgt.fade_time * 2
    )

func anim_fadeIn_bg():
  create_tween().tween_property(
    $bg, "modulate",
    Color($bg.modulate, 1),
    _sgt.fade_time
  )

func anim_fadeOut_bg():
  create_tween().tween_property(
    $bg, "modulate",
    Color($bg.modulate, 0),
    _sgt.fade_time
  )
