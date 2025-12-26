# TODO: Refactor the damn code!
# EDIT: This thing got unused. All for nothing.
extends Node2D


# Variables
var InitialTimer = 0

var txtTitle_finalposY = 140
var timer = 0
var timerFinal = 64

 #Input related
var bgsCount = 0
var bgsTimer = 0
var bgsTimerLimit = 50

var canPressStart = false


# Resources
@onready var bg 			= $bg
@onready var bg_particles1	= $bg_particles1
@onready var bg_particles2  = $bg_particles2

@onready var title			= $Title
@onready var title_txt		= $Title/txtTitle
@onready var title_txt_zoom	= $Title/txtTitle/txtZoom

@onready var start			= $PressStart
@onready var start_txt		= $PressStart/txtPressStart

@onready var fade			= $fade
@onready var bgm			= $bgm
@onready var bgs			= $bgs

# Autoloads
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')


# Main
func _ready():
  fade.visible = true
  fade.color = Color(1, 1, 1, 1)

  start.position.y = 340
  start_txt.text = tr("Title_PressStart")
  title_txt_zoom.text = title_txt.text

  Anim_FadeIn()
  Anim_txtTitle()

func _process(_delta):
  timer+=1

  if timer == timerFinal + 1:
    timer = 0
  elif timer == timerFinal / 2.0:
    Anim_TitleBump()
  
  InitialTimer += 1
  if InitialTimer >= 10:
    if Input.is_action_pressed("ui_accept") and bgsCount == 0:
      bgs.playing = true
      bgsCount=1
      
      canPressStart = true
      
      Anim_FadeOut()
      Anim_PrsStExpand()
    
    if bgsCount == 1 and bgsTimer <= bgsTimerLimit:
      bgsTimer += 1
      if bgsTimer >= bgsTimerLimit:
        _load.changeScene("res://assets/scenes/scn_mainMenu/scn_mainMenu.tscn")

# . + . + . + . + . + . + . + . + . + . + . + . + . + . + . + . + . + . + . + . 
func Anim_FadeIn():
  create_tween().tween_property(
    fade, "color",
    Color(
      fade.color.r,
      fade.color.g,
      fade.color.b,
      0), 0.5)

func Anim_FadeOut():
  create_tween().tween_property(
    fade, "color",
    Color(
      fade.color.r,
      fade.color.g,
      fade.color.b,
      1), 0.5)

func Anim_txtTitle():
  var a = create_tween()
  a.set_ease(Tween.EASE_OUT)
  a.set_trans(Tween.TRANS_CUBIC)
  a.tween_property(
    title_txt, "position", Vector2(title_txt.position.x, txtTitle_finalposY), 0.5)

func Anim_TitleBump():
  var a = create_tween()
  a.set_trans(Tween.TRANS_SINE)
  a.set_ease(Tween.EASE_IN)
  a.tween_property(title_txt, "scale", Vector2(1.1, 1.1), 0.05)
  a.set_ease(Tween.EASE_OUT)
  a.tween_property(title_txt, "scale", Vector2(1, 1), 0.5)

  #txtZoom
  var r = title_txt_zoom
  var vr = 0

  if vr <=1:
    vr+=1
  elif vr==1:
    r.scale=Vector2(1,1)
    r.modulate.a=0.2
    
    r.position=Vector2(0,0)

  var b = create_tween()
  b.set_ease(Tween.EASE_OUT)
  b.set_trans(Tween.TRANS_CUBIC)
  b.tween_property(r, "scale", Vector2(2, 2), 1)

  var c = create_tween()
  c.set_ease(Tween.EASE_OUT)
  c.set_trans(Tween.TRANS_CUBIC)
  c.tween_property(r, "position", Vector2(0, -100), 1)
  
  create_tween().tween_property(r, "modulate", Color(
    r.modulate.r,
    r.modulate.g,
    r.modulate.b,
    0),
  1)

func Anim_PrsStExpand():
  # PressStart text
  create_tween().tween_property(
    start, "modulate",
    Color(
      start.modulate.r,
      start.modulate.g,
      start.modulate.b,
      0),
    0.25)

  # Title
  var a = create_tween()
  a.set_ease(Tween.EASE_IN_OUT)
  a.set_trans(Tween.TRANS_CUBIC)
  a.tween_property(title, "scale", Vector2(2, 2), 0.8)
  
  var b = create_tween()
  b.set_ease(Tween.EASE_IN_OUT)
  b.set_trans(Tween.TRANS_CUBIC)
  b.tween_property(title, "position", Vector2(
    title.position.x - 100,
    title.position.y - 100),
  0.5)

  #Fade out the music
  create_tween().tween_property(bgm,"volume_db",-100,2)
