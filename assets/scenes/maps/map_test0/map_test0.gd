extends Node2D

# Resources
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')

@onready var chr_bell = get_node("chr_bell")
@onready var chr_bell_ray = get_node("chr_bell/ray")
@onready var label = get_node("chr_bell/label")

# Main
func _ready() -> void:
  _fade._out.emit()
  chr_bell.changeZoom(0.9, 0.5, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)

func _process(_delta) -> void:
  label.position = Vector2(20, 20)
  label.text = "Position: " + str(chr_bell.position) \
    + "\nCam zoom: " + str(chr_bell.camZoom) \
    + "\nFacing to: " + str(chr_bell_ray.target_position)
