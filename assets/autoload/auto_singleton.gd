extends Node

# Common
enum _ease {IN, OUT}

var window_size = Vector2(
  ProjectSettings.get_setting('display/window/size/viewport_width'),
  ProjectSettings.get_setting('display/window/size/viewport_height'),
)

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
func getButtonPrompt(key: String):
  return "res://assets/images/buttonprompts/" + str(key) + "_Key_Dark.png"

# Settings
# - General
var setting_fadeTime = 0.25
var settings_bgmVolume = 100
var settings_sfxVolume = 0

var settings_language_useOSLanguage: bool = false
var settings_language = "es" # DEBUG, the English language should be the default one

var fade_time = setting_fadeTime

func settings_set():
  var config = ConfigFile.new()

  config.set_value("General", "BGM Volume", settings_bgmVolume)
  config.set_value("General", "SFX Volume", settings_sfxVolume)

  config.save("res://settings.ini")

func settings_get():
  var config = ConfigFile.new()

  var err = config.load("res://settings.ini")
  if err != OK: return

  for player in config.get_sections():
    settings_bgmVolume = config.get_value("General", "BGM Volume")
    settings_sfxVolume = config.get_value("General", "SFX Volume")
