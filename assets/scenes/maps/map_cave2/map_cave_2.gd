extends Node2D

@onready var _load = get_node('/root/auto_load')
@onready var _sgt = get_node('/root/auto_singleton')

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.DARK_GRAY)
	$CharacterBella._fade_out.emit()
	
	print("flag: " + str(_sgt.flag_helper))
	
	if _sgt.flag_use_prev_position_in_scene \
	and _sgt.flag_prev_scene == _sgt.scene_outside_vespera:
		match _sgt.flag_helper:
			"Entrance":
				$CharacterBella.position = $PositionHelpers/Entrance.position
		


func _on_vespera_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_sgt.quick_prev(_sgt.scene_outside_vespera, $CharacterBella.position + Vector2(0, 40))
		
		create_tween().tween_property($CharacterBella, "camera_zoom", 2, $CharacterBella.fade_duration)
		$CharacterBella._fade_in.emit()
		
		var timer = get_tree().create_timer($CharacterBella.fade_duration)
		await timer.timeout
		
		_load.change_scene(_sgt.scene_outside_vespera, "Cave")
