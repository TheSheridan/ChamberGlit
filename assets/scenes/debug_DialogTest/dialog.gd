## Initial code
extends Control

signal fade_in
signal fade_out

@export var usable: bool = false

@export var speed = 0.2 # The speed for showing text
@export var dialog = [
	"Acabas de empezar una aventura mágica, envolvente, "
  + "\n[font_size=25]de esas que no se [shake]ven[/shake] en los videojuegos de [rainbow]ahora.",

  "Segunda línea de diálogo.",

	"Singao."
]
# The text array.
@export var fadeTime: float = 0.1

@export_enum("Top", "Center", "Down") var orientation: int
@export var orientation_multiplier: float = 20
var orientation_move: float
enum orientation_enum {
  TOP,
  CENTER,
  DOWN
}

var dialogIndex = 0
var finished = false

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

  fade_in.connect(In.bind())
  fade_out.connect(Anim_Exit.bind())

func _process(_delta) -> void:
  $ind.visible = finished

  if usable:
    if Input.is_action_just_pressed("cg_accept"):
      LoadDialog()

var tween_dialog: Tween
func LoadDialog():
  tween_dialog = create_tween()

  if dialogIndex < dialog.size():
    finished = false
    $text/txt.text = dialog[dialogIndex]
    $text/txt.visible_characters = 0
    tween_dialog.tween_property(
      $text/txt, "visible_characters",
      $text/txt.get_total_character_count(), speed)
  else:
    if Anim_Exit() != 1:
      Anim_Exit()
      dialogIndex = -1
    else:
      queue_free()
      
  dialogIndex += 1
  
  tween_dialog.finished.connect(LoadDialog_exit.bind())
    
func LoadDialog_exit():
  tween_dialog.kill()

func In():
  Anim_Enter()
  LoadDialog()

func Anim_Enter():
  #Fade in
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property(self, "modulate", Color(modulate, 1), fadeTime * 2)

  #Position
  create_tween().set_ease(Tween.EASE_OUT)\
  .set_trans(Tween.TRANS_CUBIC). \
  tween_property(self, "position:y", position.y + orientation_move, fadeTime)
  
  return 1

func Anim_Exit():
  #Fade out
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property(self, "modulate", Color(modulate, 0), fadeTime * 2)

  #Position
  var tween = create_tween().set_ease(Tween.EASE_IN_OUT) \
  .set_trans(Tween.TRANS_CUBIC)
  tween.tween_property(
    self, "position:y", position.y - orientation_move, fadeTime)


func _on_button_pressed() -> void:
  fade_in.emit()
