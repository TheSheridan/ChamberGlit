## Singleton autoload for most of all variables, flags and functions the game uses.
extends Node

@onready var _loading = $'/root/n_animLoading'
@onready var _load = $'/root/auto_load'


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

func sfx_play(sound):
	var sfx = get_node('/root/sfx/' + sound)
	sfx.volume_db = settings_sfxVolume
	sfx.play()

# Button prompts
func get_button_prompt(key: String):
	return "res://assets/images/buttonprompts/" + str(key) + "_Key_Dark.png"


# Gameplay
# - Scene stuff
func handle_dialog(bella, balloon):
	if bella.can_talk:
		if not balloon.after_closing:
			if Input.is_action_just_pressed("ui_accept"):
				if not balloon.is_running_dialog:
					bella.npc_start_now()
					bella.stand_still = true
		else:
			bella.stand_still = false
			balloon.after_closing = false
			
func check_bella_position(bella, scene_name: String):
	var helper = get_node("../" + scene_name + "/PositionHelpers/" + flag_helper)
	var after_battle = get_node("../" + scene_name + "/PositionHelpers/AfterBattle")
	
	_loading._out.emit()
	
	after_battle.position = flag_prev_position
	
	if flag_helper != "":
		bella.position = helper.position
	elif flag_helper == "AfterBattle":
		bella.position = after_battle.position
	
func fade_to_battle(bella, battle_scene):
	_loading.sprite_color = false
	bella.stand_still = true
	
	quick_prev(scene_outside_vespera, bella.position)
	sfx_play("battle")
	
	create_tween().set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property(bella, "camera_zoom", 1.0, 0.5)
	
	# BGM Tribulations
	
	# Timer
	var timer = get_tree().create_timer(1)
	await timer.timeout
	
	bella.fade_color = Color.WHITE
	bella._fade_in.emit()
	
	var timer2 = get_tree().create_timer(bella.fade_duration)
	await timer2.timeout
			
	_load.change_scene(battle_scene)

# - Bella stats
var bella_stats: Dictionary = {
	"hp"  : 20,
	"hp_max"  : 20,

	"pp"  : 40,
	"pp_max"  : 40,

	"level"  : 1,
	"exp": 0,
	
	"strength" : 7,
	"defense" : 5,
	"agility" : 10,
	"wisdom" : 8,
	"power" : 9,
}
		
func fairmath(value: float, change: float):
	return round(value - (value * (change / 100)))

func set_bella_stats():
	bella_stats.level = 1
	
	bella_stats.max_hp = 20
	bella_stats.max_mp = 40
	
	bella_stats.hp = bella_stats.max_hp
	bella_stats.mp = bella_stats.max_mp
	
	bella_stats.strength = 7
	bella_stats.defense = 5
	bella_stats.agility = 10
	bella_stats.wisdom = 6
	bella_stats.power = 8
	
	
	

func _ready():
	pass
	#set_bella_stats()


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
@export var flag_prev_scene: String
@export var flag_prev_position: Vector2
@export var flag_helper: String

func quick_prev(scene: String, pos: Vector2):
	flag_prev_scene = scene
	flag_prev_position = pos
	
	flag_use_prev_position_in_scene = true
	
func quick_scene(scene: String, helper: String):
	pass
	
	
#region (Flags)
# General
## Use previous position in the current scene?
var flag_use_prev_position_in_scene: bool = false
## We changed scenes after the battle ended?
var flag_scene_changed_after_battle: bool = false
## Will be deprecated soon...
var flag_position_helper_to_use: String = " "

# Maps
## Bridge at the Ancient Ruins.
var flag_cave1_bridge: bool = false

## While true, Bella will appear at the bed of his house. Useful for Continues.
var flag_bella_house_appear_in_bed: bool = false
## Bella accepted Ruth fetch quest?
var flag_vespera_accept_to_search_herbs: bool = false
var flag_vespera_got_herbs: bool = false
var flag_vespera_heard_about_cave: bool = false
#endregion


#region (Scene Paths)
var scene_intro_cave = "res://assets/scenes/maps/map_cave1_all/map_cave1_all.tscn"
var scene_bella_house = "res://assets/scenes/maps/map_bellahouse2/map_bellahouse_2.tscn"
var scene_vespera = "res://assets/scenes/maps/map_vespera/map_vespera.tscn"
var scene_outside_vespera = "res://assets/scenes/maps/map_outside_vespera/map_outside_vespera.tscn"

var scene_cave_2 = "res://assets/scenes/maps/map_cave2/map_cave2.tscn"

var battle_test1: String = "res://assets/scenes/battles/btl_test_1/btl_test_1.tscn"
#endregion
