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
		$CharacterBella.position = _sgt.flag_prev_position
		_sgt.flag_use_prev_position_in_scene = false
		
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
		
