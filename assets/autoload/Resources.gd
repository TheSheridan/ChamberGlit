extends Node

# -+ Main variables +-
@export var gnrl_showAnim: bool = true

@onready var col_blueThing = Color(0.07405599206686, 0.09171549975872, 0.109375)
var stg_fadeTime = 0.25
# -+ Misc variables +-
var mainMenu_bPromptFadeTime = 0.125



# Change scene (custom, using threads)
var thread: Thread
func changeScene(path: String):
  if is_instance_valid(thread) and thread.is_started():
    thread.wait_to_finish()
  
  if gnrl_showAnim: get_node('/root/animLoading').anim_fadeIn()

  thread = Thread.new()
  thread.start(changeSceneThreaded_1.bind(path))

func changeSceneThreaded_1(path: String):
  var tex = load(path)
  ChangeSceneThreaded_2.call_deferred()
  return tex

func ChangeSceneThreaded_2():
  var tex = thread.wait_to_finish()
        
  if gnrl_showAnim: get_node('/root/animLoading').anim_fadeOut()
    
  get_tree().change_scene_to_packed(tex)


# TEST: Multiple resolution support
var stretch_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
var stretch_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND

var scale_factor = 1.0
var gui_aspect_ratio = -1.0
var gui_margin = 0.0

func _ready() -> void:
  """resized.connect(self._on_resized)
  call_deferred("update_container")
  """
  pass

func update_container():
  # The code within this function needs to be run deferred to work around an issue with containers
  # having a 1-frame delay with updates.
  # Otherwise, `panel.size` returns a value of the previous frame, which results in incorrect
  # sizing of the inner AspectRatioContainer when using the Fit to Window setting.
  for _i in 2:
    if is_equal_approx(gui_aspect_ratio, -1.0):
      """# Fit to Window. Tell the AspectRatioContainer to use the same aspect ratio as the window,
			# making the AspectRatioContainer not have any visible effect.
			arc.ratio = panel.size.aspect()
			# Apply GUI offset on the AspectRatioContainer's parent (Panel).
			# This also makes the GUI offset apply on controls located outside the AspectRatioContainer
			# (such as the inner side label in this demo).
			panel.offset_top = gui_margin
			panel.offset_bottom = -gui_margin
      """
      pass
    else:
      """# Constrained aspect ratio.
			arc.ratio = min(panel.size.aspect(), gui_aspect_ratio)
			# Adjust top and bottom offsets relative to the aspect ratio when it's constrained.
			# This ensures that GUI offset settings behave exactly as if the window had the
			# original aspect ratio size.
			panel.offset_top = gui_margin / gui_aspect_ratio
			panel.offset_bottom = -gui_margin / gui_aspect_ratio

		panel.offset_left = gui_margin
		panel.offset_right = -gui_margin
    """
    pass
