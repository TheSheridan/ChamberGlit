extends Node2D


@onready var _load = get_node('/root/auto_load')
@onready var _sgt = get_node('/root/auto_singleton')

@onready var show_bird_tween: Tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

var show_bird_view: bool = false
var scene_to_change: String


func _ready():
	RenderingServer.set_default_clear_color(Color(0.653, 0.693, 0.714, 1.0))
	
	$CharacterBella._fade_out.emit()
	
	if _sgt.flag_use_prev_position_in_scene:
		if _sgt.flag_prev_scene == _sgt.scene_vespera_village \
		and _sgt.flag_scene_changed_after_battle:
			$CharacterBella.position = _sgt.flag_prev_position
		
		_sgt.flag_use_prev_position_in_scene = false
		
	match _sgt.flag_position_helper_to_use:
		"BellaHouse":
			$CharacterBella.position = $PositionHelpers/BellaHouse.position
		"TownExit":
			$CharacterBella.position = $PositionHelpers/TownExit.position
		"NPCBattle":
			$CharacterBella.position = $PositionHelpers/NPCBattle.position
		" ":
			pass
		"":
			pass
		
func _process(_delta) -> void:
	if Input.is_action_just_pressed('ui_select'):
		show_bird_view = not show_bird_view
		
		match show_bird_view:
			false:
				show_bird_tween.tween_property($CharacterBella/Camera, "zoom", 2, 0.5)
			true:
				show_bird_tween.tween_property($CharacterBella/Camera, "zoom", 1, 0.5)

func _on_bella_house_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_sgt.flag_use_prev_position_in_scene = true
		_sgt.flag_prev_position = $CharacterBella.position + Vector2(0, 20)
		
		$CharacterBella._fade_in.emit()
		await $CharacterBella/ColorRect/Timer.timeout
		
		RenderingServer.set_default_clear_color(Color.BLACK)
		_load.change_scene("res://assets/scenes/maps/map_bellahouse2/map_bellahouse_2.tscn")
		
func _on_character_bella_fade_finished() -> void:
	pass
		
func _on_outside_vespera_warp_body_entered(body: Node2D) -> void:
	_sgt.flag_position_helper_to_use = ""
	_sgt.quick_prev(_sgt.scene_vespera_village, $CharacterBella.position + Vector2(0, 40))
	
	create_tween().tween_property($CharacterBella, "camera_zoom", 1, $CharacterBella.fade_duration)
	$CharacterBella._fade_in.emit()
	
	var timer = get_tree().create_timer($CharacterBella.fade_duration)
	await timer.timeout
	
	_load.change_scene(_sgt.scene_outside_vespera)
