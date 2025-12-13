# PLAN:
# - Plain RichTextLabel with test settings for see if the setting system works
extends Control


# Resources
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')

@onready var cont_margin = get_node('cont_margin')
@onready var cont_ratio = get_node('cont_margin/cont_ratio')
@onready var label = get_node("cont_margin/cont_ratio/label")


# Main
func _ready() -> void:
	_fade._out.emit()
	cont_margin.size = _sgt.window_size

	_sgt.settings_bgmVolume = 50

	label.text = """
		SETTINGS TEXT
		Press [Accept] for save settings.

		BGM Volume: """+str(_sgt.settings_bgmVolume)+"""
		SFX Volume: """+str(_sgt.settings_sfxVolume)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_sgt.settings_set()
		print("Settings saved!")
