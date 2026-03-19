extends Node2D


@onready var _load = get_node("/root/auto_load")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed('ui_accept'):
		_load.change_scene("res://assets/scenes/scn_logo/scn_logo.tscn")
		
