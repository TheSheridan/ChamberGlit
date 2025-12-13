extends Node3D


@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")

@onready var textbox = $ui/rich_text_label
@onready var textbox_bg = $ui/color_rect

var sphere_rotation = 5
var textbox_displacement = 10

var is_your_turn: bool = false
var text_order: Array = []

var text_possible_dialogs: Array = [
  # Init
  "¡Te ha emboscado un X!",
  # Your turn
  "¿Qué harás?",
  "Lanzas un puñetazo.",
  "Eso tuvo que doler.",
  # Enemy turn
  "El enemigo te golpea.",
  # Misc
  "Tu cuerpo se tensa, pero sigues sintiéndote ligera."
]


func _ready() -> void:
  _fade._out.emit()
  create_tween().tween_property($bgm, 'volume_db', -5, 0.5)
  
  textbox.position += Vector2(textbox_displacement, textbox_displacement)
  textbox.text = \
  #"Tu cuerpo se tensa, pero sigues sintiéndote ligera."
  "¡Te ha emboscado un X!"
  
  textbox_bg.size = textbox.size


func _process(delta: float) -> void:
  $csg_sphere_3d.rotation_degrees.y += sphere_rotation * delta
  $csg_sphere_3d.rotation_degrees.z += sphere_rotation * delta
  
  if Input.is_action_just_pressed('cg_accept'):
    if !is_your_turn:
      is_your_turn = true
