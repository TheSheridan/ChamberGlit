extends Control


@onready var _sgt = get_node("/root/auto_singleton")

@export var fade_time = 0.25
@export var index = 10

var color = Color.BLACK

enum color_enum {LIGHT, DARK}

signal _in
signal _out


func _ready() -> void:	
	$BG.size = _sgt.window_size
	
	#z_index = index
  
	connect("_in", anim_fade_in.bind())
	connect("_out", anim_fade_out.bind())
  
func _process(_delta: float) -> void:
	$BG.color = color

func anim_fade_in():
	#print("Fade in")
	create_tween().tween_property(self, "modulate:a", 1, fade_time)
  
func anim_fade_out():
	#print("Fade out")
	create_tween().tween_property(self, "modulate:a", 0, fade_time)
