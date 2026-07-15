extends Node2D


@onready var _fade = get_node('/root/auto_fade')

@export var rng_size: float = 2

var text_run_prev: Vector2
var rng = RandomNumberGenerator.new()

var text_run_string: String = \
 "Corre con [" + str(InputMap.action_get_events('ui_cancel')) + "]"


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	_fade._out.emit()
	
	text_run_prev = $TextRunButton.position


func _process(_delta) -> void:
	# Shake "Press [RUN]" text
	$TextRunButton.position = lerp(
		text_run_prev,
		Vector2(
			rng.randf_range(-rng_size, rng_size),
			rng.randf_range(-rng_size, rng_size)),
		0.2
	)
	
	# TODO: Add other VFX to that text.
