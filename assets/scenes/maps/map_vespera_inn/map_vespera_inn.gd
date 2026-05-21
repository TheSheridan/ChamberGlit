extends Node2D

@onready var _sgt = $/root/auto_singleton

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

var talked_to_old_man: bool = false


func _ready() -> void:
	_sgt.check_bella_position(bella, name)
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()
	
	print(
		"Helper pos: " + str($PositionHelpers/Exit.position)
		+ "Bella pos: " + str($CharacterBella.position))
	
	#talked_to_old_man = true

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
