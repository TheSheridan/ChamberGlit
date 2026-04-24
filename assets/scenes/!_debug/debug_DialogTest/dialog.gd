## Initial code
extends Control

## The text array.
@export var dialog = [
	"Acabas de empezar una aventura mágica, envolvente, "
  + "\n[font_size=25]de esas que no se [shake]ven[/shake] en los videojuegos de [rainbow]ahora.",

  "Segunda línea de diálogo.",

	"Singao."
]
var dialog_index = 0
## The speed for showing text.
@export var speed: float = 0.2
@export var fade_time: float = 0.1

@onready var char_count: int = $text/txt.get_total_character_count()
var duration: float = char_count * speed

@export_enum("Top", "Center", "Down") var orientation: int = 1
@export var orientation_multiplier: float = 20
var orientation_move: float
enum orientation_enum {
  TOP,
  CENTER,
  DOWN
}

@export var is_usable: bool = false
var dialog_finished: bool = false

signal fade_in
signal fade_out

@onready var _fade = get_node('/root/auto_fade')

## Main code
func _ready() -> void:
  modulate = Color(modulate, 0)
  
  match orientation:
    orientation_enum.TOP:
      orientation_move = -orientation_multiplier
    orientation_enum.CENTER:
      orientation_move = 0
    orientation_enum.DOWN:
      orientation_move = orientation_multiplier
      
  position.y = orientation_move
  
  _fade._out.emit()

  fade_in.connect(start.bind())
  fade_out.connect(anim_exit.bind())


func _physics_process(_delta) -> void:
  show_indicator()

  if is_usable:
    if Input.is_action_just_pressed("ui_accept"):
      load_dialog()

func show_indicator():
  if dialog_finished:
    $ind.visible = true
  else:
    $ind.visible = false

var tween_dialog: Tween
func load_dialog():
  tween_dialog = create_tween()

  if dialog_index < dialog.size():
    $ind.visible = false
    $text/txt.text = dialog[dialog_index]
    $text/txt.visible_characters = 0

    tween_dialog = create_tween()
    tween_dialog.tween_property(
      $text/txt, "visible_characters", char_count, duration)
    tween_dialog.finished.connect(_on_tweenDialog_finished.bind())

    dialog_index += 1

    if Input.is_action_just_pressed("ui_accept"):
      $text/txt.visible_characters = char_count
    return
  else:
    #if anim_exit() != 1:
    anim_exit()
    dialog_index = -1

    return
    
func _on_tweenDialog_finished():
  dialog_finished = true
  tween_dialog = null


func start():
  anim_enter()
  load_dialog()


func anim_enter():
  #Fade in
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property(self, "modulate", Color(modulate, 1), fade_time * 2)

  #Position
  create_tween().set_ease(Tween.EASE_OUT)\
  .set_trans(Tween.TRANS_CUBIC). \
  tween_property(self, "position:y", position.y + orientation_move, fade_time)
  
  return 1

func anim_exit():
  #Fade out
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property(self, "modulate", Color(modulate, 0), fade_time * 2)

  #Position
  var tween = create_tween().set_ease(Tween.EASE_IN_OUT) \
  .set_trans(Tween.TRANS_CUBIC)
  tween.tween_property(
    self, "position:y", position.y - orientation_move, fade_time)

  return 1


func _on_button_pressed() -> void:
  fade_in.emit()
