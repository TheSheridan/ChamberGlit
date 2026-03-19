extends Node2D


@onready var _load = get_node('/root/auto_load')
@onready var _sgt = get_node('/root/auto_singleton')


func _ready() -> void:
	$CharacterBella._fade_out.emit()
	
	if _sgt.flag_bella_house_appear_in_bed:
		$CharacterBella.position = Vector2(320, 240)
	else:
		$CharacterBella.position = Vector2(928, 384)

func _on_warp_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$CharacterBella.position = Vector2(1168, 160)

func _on_warp_area_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$CharacterBella.position = Vector2(160, 160)
		
func _on_vespera_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if _sgt.flag_bella_house_appear_in_bed:
			_sgt.flag_bella_house_appear_in_bed = false
		
		$CharacterBella._fade_in.emit()
		await $CharacterBella/ColorRect/Timer.timeout
		
		_load.change_scene(_sgt.scene_vespera_village)
