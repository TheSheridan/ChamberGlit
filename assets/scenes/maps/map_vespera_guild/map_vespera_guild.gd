# This is the minimal template for a normal map.
extends Node2D


@onready var _sgt = $/root/auto_singleton

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
