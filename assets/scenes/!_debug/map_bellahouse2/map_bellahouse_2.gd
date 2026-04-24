extends Node2D


@onready var _load = get_node('/root/auto_load')
@onready var _sgt = get_node('/root/auto_singleton')

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready() -> void:
	bella._fade_out.emit()
	
	if _sgt.flag_bella_house_appear_in_bed:
		bella.position = Vector2(320, 240)
		_sgt.flag_bella_house_appear_in_bed = false
	else:
		bella.position = Vector2(928, 384)


func _on_warp_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		bella._fade_in.emit()
		var timer = get_tree().create_timer(bella.fade_duration)
		await timer.timeout
		
		bella.position = Vector2(1168, 160)
		bella._fade_out.emit()
		

func _on_warp_area_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		bella._fade_in.emit()
		var timer = get_tree().create_timer(bella.fade_duration)
		await timer.timeout
		
		bella.position = Vector2(160, 160)
		bella._fade_out.emit()
		
func _on_vespera_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if _sgt.flag_bella_house_appear_in_bed:
			_sgt.flag_bella_house_appear_in_bed = false
		
		bella._fade_in.emit()
		await bella/ColorRect/Timer.timeout
		
		_sgt.flag_position_helper_to_use = "BellaHouse"
		_load.change_scene(_sgt.scene_vespera_village)
