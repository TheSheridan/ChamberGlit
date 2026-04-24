extends Node2D


@onready var _sgt = $/root/auto_singleton

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

@export var start_in_bed: bool = false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()
	
	if start_in_bed:
		bella.position = $PositionHelpers/Bed.position

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
