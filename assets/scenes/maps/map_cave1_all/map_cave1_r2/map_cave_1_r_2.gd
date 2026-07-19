extends Node2D


@onready var _sgt = $"/root/auto_singleton"
@onready var _bgm = $"/root/bgm"

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready():
	bella._fade_out.emit()
	_sgt.check_bella_position(bella, name)
	_bgm.play_music("bgm_crypt.ogg")

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
