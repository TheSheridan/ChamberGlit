extends Control

# Variables
var track_actual = 0

enum track_list {
	BISEL
}
var track_list_name = [
	"01. Bisel"
]
var track_commentary = [
	""" \"Bisel\" \nMade in LMMS 1.3.0 Alpha, first versions date back to late 2022.\nI think it's really neat for the game, at least for the coldy maps I'm thinking to add."""
]
# Resources
@onready var bgm = $bgm
@onready var timer = $timer

@onready var cont_margin = $cont_margin
@onready var cont_ratio = $cont_margin/cont_ratio
@onready var txt = $cont_margin/cont_ratio/vsplit/vsplit_txt/cont_flow/label

@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _path = get_node('/root/auto_paths')

func _ready():
	_fade._out.emit()
	cont_ratio.size = _sgt.window_size

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('cg_accept'):
		print("Accept pressed.")
		
		match track_actual:
			track_list.BISEL:
				playMusic(_path.bgm_bisel, 0.85)
		
		txt.text = track_commentary[track_actual]
		
		print(bgm.stream)

func playMusic(path, pitch):
	bgm.stream = load(path)
	bgm.pitch_scale = pitch
	bgm.play()
