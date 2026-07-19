extends Node2D


var text_run_prev: Vector2
var rng = RandomNumberGenerator.new()

var text_run_string: String = \
 "Corre con [" + str(InputMap.action_get_events('ui_cancel')) + "]"

@export var rng_size: float = 2

@onready var _sgt = $"/root/auto_singleton"

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()
	
	text_run_prev = $TextRunButton.position
	
	print(scene_file_path)
	_sgt.check_bella_position(bella, name)


func _process(_delta) -> void:
	_sgt.handle_dialog(bella, balloon)
	
	# Shake "Press [RUN]" text
	$TextRunButton.position = lerp(
		text_run_prev,
		Vector2(
			rng.randf_range(-rng_size, rng_size),
			rng.randf_range(-rng_size, rng_size)),
		0.2
	)
	
	# TODO: Add other VFX to that text.
