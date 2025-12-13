## Handles saving and loading in the game.
## This node also shows an indicator at the corner of the screen.

extends Control

# Variables
## Default color of the indicator. It should match the fade's color.
@export_enum("Light", "Dark") var color: int
## Indicator rotation speed.
var rotate = 3
## Indicator margin on the screen.
var margin = 40
##
var shadow_alpha = 0.25
var fade_speed = 0.25

# Resources
var spr_loading_dark  = load("res://assets/images/loading.png")
var spr_loading_light = load("res://assets/images/loading_white.png")

@onready var cont_margin = $cont_margin
@onready var cont_ratio  = $cont_margin/cont_ratio
@onready var spr = $cont_margin/cont_ratio/spr
@onready var spr_shadow = $cont_margin/cont_ratio/spr_shadow

@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')

# Main
func _ready() -> void:
		_fade.color = _fade.color_enum.LIGHT

		cont_margin.size = _sgt.window_size
		spr.scale = Vector2(2, 2)
		spr.position = _sgt.window_size - Vector2(margin, margin)

		spr_shadow.scale = spr.scale
		spr_shadow.position     = spr.position

		z_index = 10
		spr.z_index = z_index + 1
		spr_shadow.z_index = spr.z_index - 1

		#   _fade._out.emit()

func _process(_delta: float) -> void:
		spr.rotation_degrees += rotate

		# Color
		match _fade.color:
				_fade.color_enum.LIGHT:
						color = 1 # Dark
				_fade.color_enum.DARK:
						color = 0 # Light
		
		match color:
				0:
						spr.texture = spr_loading_light
						spr_shadow.modulate = Color(Color.WHITE, shadow_alpha)
				1:
						spr.texture = spr_loading_dark
						spr_shadow.modulate = Color(Color.BLACK, shadow_alpha)
		
		print(
				"color: " + str(spr_shadow.modulate)
				+ "\nz_index: " + str(spr_shadow.z_index)
				+ "\nposition: " + str(spr_shadow.position)
				+ '\n'
		)

# Animations
func anim_fade_in():
		create_tween().tween_property(
				self, "modulate", Color(modulate, 1), fade_speed
		)
func anim_fade_out():
		create_tween().tween_property(
				self, "modulate", Color(modulate, 0), fade_speed * 2
		)
