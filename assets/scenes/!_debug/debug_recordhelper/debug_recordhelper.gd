extends Node2D


@onready var _load = get_node("/root/auto_load")


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.DARK_GRAY)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('ui_accept'):
		_load.change_scene("res://assets/scenes/battles/btl_test_1/btl_test_1.tscn")
		
