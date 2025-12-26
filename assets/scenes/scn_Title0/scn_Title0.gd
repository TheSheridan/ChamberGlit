extends Node2D
# TODO: Keep developing the scene
# TODO: Refactor the code
# TODO: When it's cristmas put a snowflake sprite
# instead to the lighting one in particles1


# Variables
@export var TxtGlit_limits = 4
var prevBGMvol
var prevTxtGlitPos
var prevPstartGlitPos: Vector2

  # _process
var timer 		= 0
var timerStop: bool = false

var t_sprGlit2  = 0
var t_spr	    = 0
var t_sprExpand = 0

var bgCol 		= Color(0, 0, 0, 1)

var lerpTime 	= 0.5

  # _physics_process
@export var PressStart_sceneToChange: StringName
var PressStart_switch:bool=false
var PressStart_timer:int

  # Anim_sprExpand()
var Anim_sprExpand_timer = 0
var Anim_sprExpand_timerLimit = 120
var Anim_sprExpand_tween: Tween
  #
var Anim_sprExpand_rot_frq: float = 15
var Anim_sprExpand_rot_amp: float = 45
var Anim_sprExpand_rot_time = 0


# Resources
# DONE
@onready var bgm = $bgm
@onready var cam = $cam

@onready var particles = $particles
@onready var particles1 = $particles/n1
@onready var particles2 = $particles/n2
@onready var particles3 = $particles/n3

@onready var txt 			= $txt
@onready var txt_glit 		= $txt/txt_glit
@onready var txt_glow 		= $txt/glowLine
@onready var txt_glow_up    = $txt/glowLine/up
@onready var txt_glow_down  = $txt/glowLine/down

@onready var logo 			= $logo
@onready var logo_spr 		= $logo/spr
@onready var logo_spr_glit 	= $logo/spr_glit
@onready var logo_spr_glit2 = $logo/spr_glit2
@onready var logo_spr_expand = $logo/spr_expand
@onready var logo_spr_glow 	= $logo/glow

@onready var start = $pStart
@onready var start_txt = $pStart/txt
@onready var start_txt_glit = $pStart/txt_glit

@onready var msg = $crMsg

@onready var grad1 = $grd1
@onready var grad2 = $grd2

@onready var label = $label


# Autoloads
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')


# Main
func _ready():
  RenderingServer.set_default_clear_color(Color.BLACK)

  bgm.playing = true
  prevBGMvol  = AudioServer.get_bus_volume_db(1)
  AudioServer.set_bus_volume_db(1, -6)

  particles1.position = -Vector2(10, 10)

  particles3.position = Vector2(-35, _sgt.window_size.x / 2)
  particles3.modulate = Color(particles3.modulate, 0.05)

  txt.size.x       		= _sgt.window_size.x
  txt.pivot_offset 		= Vector2(txt.size.x/2, txt.size.y/2)
  txt.text         		= tr("Title2_GameByDev")
  txt.visible_characters  = 0
  txt.modulate 	        = Color(txt.modulate,0)

  txt_glit.size 		= txt.size
  prevTxtGlitPos 		= txt_glit.position
  prevPstartGlitPos 	= start_txt_glit.position

  txt_glow.size = Vector2(
    _sgt.window_size.x,
    _sgt.window_size.y/12
  )
  txt_glow.modulate = Color(txt_glow.modulate, 0)

  txt_glow_up.scale.x   = _sgt.window_size.x
  txt_glow_down.scale.x = _sgt.window_size.x

  logo.modulate   = Color(logo.modulate,0)
  logo.size.x     = _sgt.window_size.x
  logo.position.x = _sgt.window_size.x / 2
  logo.position.y = _sgt.window_size.y / 2 - _sgt.window_size.y / 30

  logo_spr_expand.rotation_degrees = -2.5
  logo_spr_expand.modulate = Color(logo_spr_expand.modulate, 0.2)

  start.size.x 		= logo.size.x
  start.modulate 		= Color(start.modulate, 0)
  start_txt.text 		= tr('Title2_PressStart_Any')
  start_txt_glit.text = tr('Title2_PressStart_Any')

  grad1.position 				= Vector2(0, 0)
  grad1.region_rect.size.y 	= _sgt.window_size.y / 8
  grad1.scale 				= Vector2(_sgt.window_size.x, 1)

  grad2.position 				= Vector2(0, _sgt.window_size.y - grad2.region_rect.size.y)
  grad2.region_rect.size.y 	= _sgt.window_size.y / 8
  grad2.scale 				= Vector2(_sgt.window_size.x,1)

  create_tween() 			      \
  .set_ease(Tween.EASE_OUT)     \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property(txt, 'position:y',
    _sgt.window_size.y / 2 - _sgt.window_size.y / 30,
    0.9
  )
  
  Anim_sprExpand_tween = create_tween().set_trans(Tween.TRANS_SINE)\
    .set_ease(Tween.EASE_IN_OUT)

  start.position.y = _sgt.window_size.y - _sgt.window_size.y / 4
  create_tween().tween_property(start, 'modulate', Color(start.modulate, 1), 0.5)

  msg.size 			= _sgt.window_size
  msg.pivot_offset.y 	= msg.size.y
  msg.position.y 		= (_sgt.window_size.y) - (_sgt.window_size.y / 15)

  $cam.offset = Vector2(_sgt.window_size) / 2

func exitingToOtherScene():
  var a = create_tween().tween_property(bgm, 'volume_db', -50, 0.5)
  if a.finished:
    AudioServer.set_bus_volume_db(1, prevBGMvol)
  _fade._in.emit()

func _process(delta):
  #EssentialFunction()
  
  RenderingServer.set_default_clear_color(bgCol)
  create_tween().tween_property(
    self,'bgCol',
    Color(0.07405599206686, 0.09171549975872, 0.109375),
    0.25)

  if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_ALT) \
  and Input.is_key_pressed(KEY_R):
    get_tree().change_scene_to_file('res://internal/scenes/scn_Title0/scn_Title0.tscn')

  if timerStop == false: timer += 1
  label.text = 'Anim_sprExpand_timer='+str(Anim_sprExpand_timer)\
  + '\nlogo_spr_expand.scale = ' + str(logo_spr_expand.scale)

  #create_tween().tween_property(txt,'modulate',Color(txt.modulate,1),0.3)
  #create_tween().tween_property(txt_glow,'modulate',Color(txt_glow.modulate,0.25),1)

  # Typewriter effect
  if txt.visible_characters != txt.get_total_character_count():
    txt.visible_characters+=1
  if txt_glit.visible_characters != txt.get_total_character_count():
    txt_glit.visible_characters+=1
  txt_glit.text = txt.text


  # Text glit
  logo_spr_glit2.position = Vector2(
    prevTxtGlitPos.x + RandomNumberGenerator.new().randf_range(-2.5,2.5),
    prevTxtGlitPos.y + RandomNumberGenerator.new().randf_range(-2.5,2.5)
  )
  logo_spr.offset = Vector2(
    RandomNumberGenerator.new().randf_range(-0.2,0.2),
    RandomNumberGenerator.new().randf_range(-0.3,0.3)
  )
  start_txt_glit.position = Vector2(
    prevPstartGlitPos.x+RandomNumberGenerator.new().randf_range(-2.5,2.5),
    prevPstartGlitPos.y+RandomNumberGenerator.new().randf_range(-2.5,2.5)
  )
    

  # txt.position movement
  #if timer==1: create_tween().set_trans(Tween.TRANS_SINE).tween_property(txt,'position:y',_sgt.window_size.y,0.25)
  
  if timer==2:
    create_tween().set_trans(Tween.TRANS_CUBIC)\
    .set_ease(Tween.EASE_OUT)\
    .tween_property(logo, 'position:y',
      (_sgt.window_size.y / 2), 0.5)
    
    create_tween().tween_property(logo, 'modulate', Color(logo.modulate, 1), 0.25)

    timerStop=true
  
  Anim_sprExpand()
  Anim_sprGlitAlpha(delta)

  # Press Start
  if Input.is_anything_pressed() and PressStart_switch == false:
    create_tween().set_ease(Tween.EASE_IN)\
    .set_trans(Tween.TRANS_CUBIC)\
    .tween_property($cam, 'zoom', Vector2(8,8), 0.5)

    create_tween().set_ease(Tween.EASE_IN)\
    .set_trans(Tween.TRANS_CUBIC)\
    .tween_property(self, 'modulate', Color(modulate, 0), 0.25)

    create_tween().tween_property(bgm, 'volume_db', -50, 1)

    PressStart_switch = true
  if PressStart_switch == true: PressStart_timer += 1
  if PressStart_timer == 20:
    $cam.zoom = Vector2(1,1)
    _load.changeScene("res://assets/scenes/scn_mainMenu/scn_mainMenu.tscn")

func _physics_process(delta):
  Anim_sprExpand_rot(delta)

  txt_glit.position = \
  #lerp(
  #	prevTxtGlitPos,
  #	prevTxtGlitPos + Vector2(
  #		RandomNumberGenerator.new().randf_range(-2,2),
  #		RandomNumberGenerator.new().randf_range(-2,2)
  #	), lerpTime
  #)
  prevTxtGlitPos + Vector2(
    RandomNumberGenerator.new().randf_range(-2,2),
    RandomNumberGenerator.new().randf_range(-2,2)
  )

  logo_spr_glit.position = txt_glit.position

func Anim_sprExpand():
  # Zoom
  Anim_sprExpand_timer += 1
  if Anim_sprExpand_timer >= Anim_sprExpand_timerLimit: Anim_sprExpand_timer = 0
  
  if Anim_sprExpand_timer == 1:
    create_tween().set_trans(Tween.TRANS_SINE)\
    .set_ease(Tween.EASE_IN_OUT)\
    .tween_property(logo_spr_expand, 'scale', Vector2(2.05,2.05), 1)
  if Anim_sprExpand_timer == float(Anim_sprExpand_timerLimit / 2):
    create_tween().set_trans(Tween.TRANS_SINE)\
    .set_ease(Tween.EASE_IN_OUT)\
    .tween_property(logo_spr_expand, 'scale', Vector2(1.8,1.8), 1)

func Anim_sprExpand_rot(delta):
  Anim_sprExpand_rot_time += delta
  var move = sin(Anim_sprExpand_rot_time * Anim_sprExpand_rot_frq) * Anim_sprExpand_rot_amp
  logo_spr_expand.rotation_degrees += move * delta

var Anim_sprGlitAlpha_time: int
func Anim_sprGlitAlpha(delta):
  Anim_sprGlitAlpha_time += delta
  var move = sin(Anim_sprGlitAlpha_time * 15) * 45

  logo_spr_glit.modulate.a  += move * delta
  logo_spr_glit2.modulate.a += move * delta
