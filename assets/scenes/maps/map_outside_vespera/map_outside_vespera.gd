extends Node2D


@onready var _sgt = $/root/auto_singleton

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.653, 0.693, 0.714, 1.0))
	
	bella.camera_zoom = 1
	bella._fade_out.emit()
	_sgt.check_bella_position(bella, name)
	
	if _sgt.flag_minotaur_beated:
		$NpcChaserSlime.queue_free()
	
	# Debug
	#_sgt.flag_minotaur_beated = true
	
func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
	
	# Move shader
	var input = bella.get_input()
	var worldmap_shader = $Worldmap.material
	var mode7_transform = worldmap_shader.get_shader_parameter("TRANSFORM")
	
	#print(mode7_transform.w[0])
	#
	#match input:
		#Vector2.LEFT:
			##mode7_transform.w[0] += 1.0
			#worldmap_shader.set_shader_parameter("TRANSFORM", Transform2D(
			#))
