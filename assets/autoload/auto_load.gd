extends Control


@onready var _fade = get_node('/root/auto_fade')
@onready var _sgt = get_node('/root/auto_singleton')

# -+ Main variables +-
@export var can_show_anim: bool = true

@onready var color = Color(0.07405599206686, 0.09171549975872, 0.109375)
# -+ Misc variables +-
var fade_time_prompt = 0.125


# Change scene (custom, using threads)
var thread: Thread
func change_scene(path: String, helper: String = ""):
	_sgt.flag_helper = helper
	
	if is_instance_valid(thread) and thread.is_started():
		thread.wait_to_finish()
  
	if can_show_anim:
		_fade._in.emit()

	thread = Thread.new()
	thread.start(change_scene_threaded_1.bind(path))

func change_scene_threaded_1(path: String):
	var tex = load(path)
	change_scene_threaded_2.call_deferred()
	return tex

func change_scene_threaded_2():
	var tex = thread.wait_to_finish()
		
	if can_show_anim:
		_fade._out.emit()

	get_tree().change_scene_to_packed(tex)
