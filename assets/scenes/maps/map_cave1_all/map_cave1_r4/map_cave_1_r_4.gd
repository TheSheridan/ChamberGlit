extends Node2D


@onready var _sgt = $"/root/auto_singleton"
@onready var _load = $"/root/auto_load"
@onready var _loading = $"/root/n_animLoading"
@onready var _bgm = $"/root/bgm"

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()
	print(name + type_convert(name, TYPE_STRING))
	_sgt.check_bella_position(bella, name)

func _process(delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)

func door_cutscene():	
	print("By the way, I haven't finished this cutscene. Enjoy :3")
	
	bella.stand_still = true
	
	var cam_prev_pos: Vector2 = $CharacterBella/Camera.position
	
	# Fade BGM
	_bgm.fade_out(1.0)
	
	# Move camera
	create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property($CharacterBella/Camera, "position", cam_prev_pos + Vector2(0, -50), 1)
		
	create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property($CharacterBella, "camera_zoom", 1, 1)
	
	# Wait
	var timer = get_tree().create_timer(1)
	await timer.timeout
	
	_sgt.flag_bella_house_appear_in_bed = true
	_sgt.flag_bella_house_after_cave1 = true
	
	bella.fade_color = Color.WHITE
	bella._fade_in.emit()
	
	var timer3 = get_tree().create_timer(1)
	await timer3.timeout
	
	_loading.sprite_color = 0
	_load.change_scene(_sgt.scene_bella_house)

func _on_gate_cutscene_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		door_cutscene()
