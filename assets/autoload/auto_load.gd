extends Control

# -+ Main variables +-
@export var canShowAnimation: bool = true

@onready var col_blueThing = Color(0.07405599206686, 0.09171549975872, 0.109375)
# -+ Misc variables +-
var fade_time_prompt = 0.125

@onready var _fade = get_node('/root/auto_fade')



# Change scene (custom, using threads)
var thread: Thread
func changeScene(path: String):
  if is_instance_valid(thread) and thread.is_started():
    thread.wait_to_finish()
  
  if canShowAnimation:
    _fade._in.emit()

  thread = Thread.new()
  thread.start(changeSceneThreaded_1.bind(path))

func changeSceneThreaded_1(path: String):
  var tex = load(path)
  ChangeSceneThreaded_2.call_deferred()
  return tex

func ChangeSceneThreaded_2():
  var tex = thread.wait_to_finish()
        
  if canShowAnimation:
    _fade._out.emit()
    
  get_tree().change_scene_to_packed(tex)
