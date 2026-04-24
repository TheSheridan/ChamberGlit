extends Node2D


@onready var _sgt = $/root/auto_singleton

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.653, 0.693, 0.714, 1.0))
	
	bella.camera_zoom = 1
	bella._fade_out.emit()
	_sgt.check_bella_position(bella, name)
	
func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
