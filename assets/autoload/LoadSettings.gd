extends Node

# -+-
# Variables
@onready var windowSize: Vector2 = Vector2(
  ProjectSettings.get_setting('display/window/size/viewport_width'),
  ProjectSettings.get_setting('display/window/size/viewport_height') )

  # Window-related
@onready var FastSettings_res:Array=[
  Vector2(640,480),
  Vector2(800,600),
  Vector2(1024,768),
  Vector2(1280,720),
  Vector2(1366,768),
  Vector2(1400,600)]
var wSize:Vector2 = Vector2(1280,700)
# -+-



@onready var os_name = OS.get_name()

'''
func _enter_tree():
	## -+- Trying to adjust the viewport resolution by code (in progress) -+- ##
	var conf = ConfigFile.new()
  var err = conf.load('res://Settings.ini')
	if err != OK: return

  #ProjectSettings.set_setting('display/window/size/viewport_width_override',
	#	conf.get_value("Game window", "Screen width  (X)") )
  #ProjectSettings.set_setting('display/window/size/viewport_height_override',
	#	conf.get_value("Game window", "Screen height  (Y)") )
	
	#get_viewport().set_size_override_stretch(true)
	#get_viewport().set_size_override(true, wSize)

	#get_window().size = wSize
	ProjectSettings.set_setting("display/window/size/window_width_override", "expand")
	#RenderingServer.viewport_set_size(get_viewport().get_viewport_rid(), wSize.x, wSize.y)
	#DisplayServer.window_set_size(wSize)

	## -+- Other things -+- ##
  #ProjectSettings.set_setting('display/window/size/borderless',false)
	#if get_window().borderless==true: get_window().borderless=false

  #DisplayServer.set_icon(load('res://assets/images/logo_cg.png')) #I think this doesn't work...
  TranslationServer.set_locale('es')

func _process(delta):
  # Window mode
  if Input.is_action_just_pressed('WindowMode'):
    if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_WINDOWED:
      DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
    elif DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
      DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

  #SettingsFast

  if Input.is_action_just_pressed('SettingsFast'): pass
    #OS.alert('Este es un mensaje de prueba.\nSi está mostrado en tu pantalla...\n¡Enhorabuena! Todo ha salido a la perfección.\n\t\t\t- AlgoRythm', 'ChamberGlit')
  """
		if not FastSettings_resInd==FastSettings_res.size()-1:
			FastSettings()

			ProjectSettings.set_setting('display/window/size/viewport_width',wSize.x)
			ProjectSettings.set_setting('display/window/size/viewport_height',wSize.y)
			RenderingServer.viewport_set_size(get_viewport().get_viewport_rid(),wSize.x,wSize.y)
			DisplayServer.window_set_size(wSize)
		else:
			print('ya')

			FastSettings_resInd=0
			wSize=FastSettings_res[0]

			ProjectSettings.set_setting('display/window/size/viewport_width',wSize.x)
			ProjectSettings.set_setting('display/window/size/viewport_height',wSize.y)
			RenderingServer.viewport_set_size(get_viewport().get_viewport_rid(),wSize.x,wSize.y)
  """

#func test(): print("test function in \"LoadSettings.gd\" called successfully...")

var FastSettings_resInd:int
func FastSettings():
  FastSettings_resInd+=1
  wSize=FastSettings_res[FastSettings_resInd]
'''
