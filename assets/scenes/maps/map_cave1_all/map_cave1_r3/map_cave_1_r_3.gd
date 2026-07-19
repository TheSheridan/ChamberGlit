extends Node2D


@onready var _sgt = $"/root/auto_singleton"

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()
	_sgt.check_bella_position(bella, name)

func _process(delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
	
	match _sgt.flag_cave1_bridge:
		false:
			$BridgeBlock.show()
		true:
			$BridgeBlock.hide()
			$BridgeBlock.position.y = -1332.0
