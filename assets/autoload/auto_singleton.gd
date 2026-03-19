extends Node


# Common
enum _ease {IN, OUT}

var window_size = Vector2(
	ProjectSettings.get_setting('display/window/size/viewport_width'),
	ProjectSettings.get_setting('display/window/size/viewport_height'),
)

var window_position = DisplayServer.window_get_size()

func music_play(node, fade, time):
	match fade:
		_ease.IN:
			create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC) \
			.tween_property(node, "volume_db", -40.0, time)
		_ease.OUT:
			create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC) \
			.tween_property(node, "volume_db", 0.0, time)

func sfx_play(sfx):
	var _sfx = get_node('/root/sfx/' + sfx)
	_sfx.volume_db = settings_sfxVolume
	_sfx.play()

# Button prompts
func get_button_prompt(key: String):
	return "res://assets/images/buttonprompts/" + str(key) + "_Key_Dark.png"

# Settings
# - General
var setting_fadeTime = 0.25
var settings_bgmVolume = 100
var settings_sfxVolume = 0

var settings_language_useOSLanguage: bool = false
var settings_language = "es" # DEBUG, the English language should be the default one

var fade_time = setting_fadeTime

func get_setting():
	var config = ConfigFile.new()

	var err = config.load("res://settings.ini")
	if err != OK: return

	for player in config.get_sections():
		settings_bgmVolume = config.get_value("General", "BGM Volume")
		settings_sfxVolume = config.get_value("General", "SFX Volume")

func set_setting():
	var config = ConfigFile.new()

	config.set_value("General", "BGM Volume", settings_bgmVolume)
	config.set_value("General", "SFX Volume", settings_sfxVolume)

	config.save("res://settings.ini")


# Flags
var flag_prev_scene: String
var flag_prev_position: Vector2

func quick_prev(scene: String, pos: Vector2):
	flag_prev_scene = scene
	flag_prev_position = pos
	
var flag_use_prev_position_in_scene: bool = false	
	
var flag_bella_house_appear_in_bed: bool = false


# Scene paths
var scene_intro_cave: String = "res://assets/scenes/maps/map_cave1_all/map_cave1_all.tscn"
var scene_bella_house: String = "res://assets/scenes/maps/map_bellahouse2/map_bellahouse_2.tscn"
var scene_vespera_village: String = "res://assets/scenes/maps/map_vespera_village/map_vespera_village.tscn"

var battle_test1: String = "res://assets/scenes/battles/btl_test_1/btl_test_1.tscn"
