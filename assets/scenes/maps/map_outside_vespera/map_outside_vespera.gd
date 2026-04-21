extends Node2D


@onready var _load = get_node('/root/auto_load')
@onready var _sgt = get_node('/root/auto_singleton')


func _ready():
	RenderingServer.set_default_clear_color(Color.DARK_GRAY)
	
	$CharacterBella._fade_out.emit()
	$CharacterBella.camera_zoom = 1
	$CharacterBella.textbox_scale = 1
	
	print("Position helper:" + str(_sgt.flag_helper))
	
	check_bella_position()

func check_bella_position():
	if _sgt.flag_use_prev_position_in_scene \
	and _sgt.flag_prev_scene == _sgt.scene_outside_vespera:
		$CharacterBella.position = _sgt.flag_prev_position
		
		if _sgt.flag_helper != "":
			$CharacterBella.position = get_node("PositionHelpers/" + _sgt.flag_helper).position

func _on_vespera_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_sgt.quick_prev(_sgt.scene_outside_vespera, $CharacterBella.position + Vector2(0, -40))
		
		create_tween().tween_property($CharacterBella, "camera_zoom", 2, $CharacterBella.fade_duration)
		$CharacterBella._fade_in.emit()
		
		var timer = get_tree().create_timer($CharacterBella.fade_duration)
		await timer.timeout
		
		_load.change_scene(_sgt.scene_vespera_village, "VillageExit")

func _on_cave_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_sgt.quick_prev(_sgt.scene_outside_vespera, $CharacterBella.position + Vector2(0, 40))
		
		create_tween().tween_property($CharacterBella, "camera_zoom", 2, $CharacterBella.fade_duration)
		$CharacterBella._fade_in.emit()
		
		var timer = get_tree().create_timer($CharacterBella.fade_duration)
		await timer.timeout
		
		_load.change_scene(_sgt.scene_cave_2, "Entrance")
