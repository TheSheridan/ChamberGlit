extends Node2D


@onready var _load = get_node('/root/auto_load')
@onready var _sgt = get_node('/root/auto_singleton')

@onready var show_bird_tween: Tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)

var show_bird_view: bool = false
var scene_to_change: String


func _ready():
	print("Position helper:" + str(_sgt.flag_helper))
	
	RenderingServer.set_default_clear_color(Color(0.653, 0.693, 0.714, 1.0))
	
	$CharacterBella._fade_out.emit()
	check_bella_position()
		
func _process(_delta) -> void:
	if Input.is_action_just_pressed('ui_select'):
		show_bird_view = not show_bird_view
		
		match show_bird_view:
			false:
				show_bird_tween.tween_property($CharacterBella/Camera, "zoom", 2, 0.5)
			true:
				show_bird_tween.tween_property($CharacterBella/Camera, "zoom", 1, 0.5)

func check_bella_position():
	if _sgt.flag_use_prev_position_in_scene \
	and _sgt.flag_prev_scene == _sgt.scene_outside_vespera:
		$CharacterBella.position = _sgt.flag_prev_position
		
		if _sgt.flag_helper != "":
			$CharacterBella.position = get_node("PositionHelpers/" + _sgt.flag_helper).position

func _on_bella_house_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_sgt.flag_prev_position = $CharacterBella.position + Vector2(0, 20)
		
		$CharacterBella._fade_in.emit()
		await $CharacterBella/ColorRect/Timer.timeout
		
		RenderingServer.set_default_clear_color(Color.BLACK)
		_load.change_scene(_sgt.scene_bella_house)
		
func _on_character_bella_fade_finished() -> void:
	pass
		
func _on_outside_vespera_warp_body_entered(body: Node2D) -> void:
	_sgt.quick_prev(_sgt.scene_vespera_village, $CharacterBella.position + Vector2(0, 40))
	
	create_tween().tween_property($CharacterBella, "camera_zoom", 1, $CharacterBella.fade_duration)
	$CharacterBella._fade_in.emit()
	
	var timer = get_tree().create_timer($CharacterBella.fade_duration)
	await timer.timeout
	
	_load.change_scene(_sgt.scene_outside_vespera, "VesperaVillage")
