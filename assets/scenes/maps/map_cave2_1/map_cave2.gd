extends Node2D


@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

@onready var _sgt = $/root/auto_singleton
@onready var _bgm = $"/root/bgm"


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()
	
	if not _sgt.flag_vespera_heard_about_cave:
		$Warps/Dungeon.queue_free()
	
	_bgm.play_music("bgm_cave.ogg", 0.7)
	_bgm.stop_bg()

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
