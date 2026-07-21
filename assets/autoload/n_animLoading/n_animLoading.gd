extends CanvasLayer


@export_enum("Night", "Light") var sprite_color: int = 1
@export_enum("Night", "Light") var bgColor:     int = 0

var sprite_night = load("res://assets/images/loading.png")
var sprite_light = load("res://assets/images/loading_white.png")

signal _in
signal _out
signal finished

@onready var _sgt = $"/root/auto_singleton"

@onready var control = $Control
@onready var margin = $Control/Margin
@onready var sprite = $Control/Margin/Sprite
@onready var bg = $Control/BG

var tween: Tween

func _ready() -> void:
	control.modulate = Color(control.modulate, 0)
	
	_in.connect(anim_fadeIn.bind())
	_out.connect(anim_fadeOut.bind())

func _process(_delta: float) -> void:
	match sprite_color:
		0: sprite.texture = sprite_night
		1: sprite.texture = sprite_light
		
	match bgColor:
		0: bg.color = Color.BLACK
		1: bg.color = Color.WHITE

	sprite.rotation_degrees += 1
	if sprite.rotation_degrees >= 360:
		sprite.rotation_degrees = 0


func anim_fadeIn():
	tween = create_tween()
	
	tween.tween_property(
		control, "modulate",
		Color(control.modulate, 1),
		_sgt.fade_time
	)
	
	await tween.finished
	finished.emit()
	if is_instance_valid(tween):
		tween.kill()

func anim_fadeOut():
	tween = create_tween()
	
	tween.tween_property(
		control, "modulate",
		Color(control.modulate, 0),
		_sgt.fade_time * 2
	)
	
	await tween.finished
	finished.emit()
	if is_instance_valid(tween):
		tween.kill()

func anim_fadeIn_bg():
	tween.tween_property(
		bg, "control.modulate",
		Color(bg.modulate, 1),
		_sgt.fade_time
	)

func anim_fadeOut_bg():
	tween.tween_property(
		bg, "control.modulate",
		Color(bg.modulate, 0),
		_sgt.fade_time
	)
