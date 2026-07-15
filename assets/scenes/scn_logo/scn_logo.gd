extends Control

## Default is 1.0
@export var wait_time = 1.0

@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")
@onready var _load = get_node("/root/auto_load")
@onready var _touchpad = $"/root/Touchpad"

@onready var Sprite = $CenterContainer/Sprite
@onready var SpriteAnim = $CenterContainer/Sprite/AnimationPlayer

func _ready() -> void:
	_touchpad.transparency = 0
	
	$BG.texture.width = _sgt.window_size.x
	$BG.texture.height = _sgt.window_size.y

	_fade._out.emit()
	RenderingServer.set_default_clear_color(Color.BLACK)
  
	$Audio.volume_db = 5
	
	Sprite.modulate = Color(Sprite.modulate, 0)
	SpriteAnim.play("appear")
  
	$Audio.play(0)
	$Timer.start(wait_time)

func _process(delta) -> void:
	$BG.texture.noise.fractal_weighted_strength += 50 * delta

func _on_timer_timeout():
	create_tween().tween_property($Audio, 'volume_db', -50, _sgt.fade_time * 26)
	SpriteAnim.play("disappear")
	_fade._in.emit()
	_load.change_scene("res://assets/scenes/scn_Title0/scn_Title0.tscn")
	# DEBUG
	#get_tree().quit()
