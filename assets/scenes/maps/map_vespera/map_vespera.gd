extends Node2D


@onready var _sgt = $/root/auto_singleton
@onready var _load = $/root/auto_load

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

var npc_battle_enter: bool

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.653, 0.693, 0.714, 1.0))
	bella._fade_out.emit()
	
	print("helper: " + str(_sgt.flag_helper))
	
	_sgt.check_bella_position(bella, name)

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)


func _on_npc_battle_finished() -> void:
	_sgt.quick_prev(_sgt.scene_vespera, bella.position)
		
	bella.can_talk = false
	bella.fade_color = Color.WHITE
	bella._fade_in.emit()
	
	var timer = get_tree().create_timer(bella.fade_duration)
	await timer.timeout
	
	_load.change_scene(_sgt.battle_test1)
