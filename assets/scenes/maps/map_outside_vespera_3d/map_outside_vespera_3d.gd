extends Node3D


@onready var _sgt = $"/root/auto_singleton"
@onready var _save = $'/root/SaveAndLoad'
@onready var _bgm = $"/root/bgm"


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	_sgt.check_bella_position_3d($CharacterBella3D, name)
	_bgm.play_bg("bgm_fightover.ogg")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		_save.load_game()
		print("Game loaded")
