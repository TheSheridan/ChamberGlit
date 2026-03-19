extends Node2D


@onready var _fade = get_node('/root/auto_fade')
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _load = get_node('/root/auto_load')

## DEBUG variable!
@export var appear_normally: bool = true

@export var pause_music_time: float = 0.1
var pause_music_tween: Tween = null

var locations: Array = [
	# R1 - R2
	Vector2(350, -1696),
	Vector2(4050, -1408),
	# R2 - R3
	Vector2(9184, -1472),
	Vector2(5576, -728),
	# R3 - R4
	Vector2(14448, -832),
	Vector2(12064, -896),
]


func _ready():
	$CharacterBella._fade_out.emit()
	
	if appear_normally:
		$CharacterBella.position = Vector2(336, 216)
	
func _process(delta: float) -> void:
	_fade.position = $CharacterBella.position - _sgt.window_size / 2


func pause_music():
	pause_music_tween = create_tween()
	pause_music_tween.tween_property($Audio, "volume_db", -100, pause_music_time)

func resume_music():
	pause_music_tween = create_tween()
	pause_music_tween.tween_property($Audio, "volume_db", 0, pause_music_time)

func warp(warp_position: Vector2):
	$CharacterBella._fade_in.emit()
	$Timer.start(_fade.fade_time)
	await $Timer.timeout
	
	$CharacterBella.position = warp_position
	
	$CharacterBella._fade_out.emit()
	$Timer.start(_fade.fade_time)
	await $Timer.timeout

# - Warps -
func _on_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		warp(locations[1])

func _on_warp_l_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		warp(locations[0])

func _on_warp_r_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		warp(locations[2])

func _on_r_3_warp_l_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		warp(locations[3])

func _on_r_3_warp_r_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		warp(locations[4])

func _on_r_4_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		warp(locations[5])

func _on_npc_test_exited_area() -> void:
	pass # Replace with function body.

func _on_bella_house_warp_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		_sgt.flag_bella_house_appear_in_bed = true
		_load.change_scene(_sgt.scene_bella_house)
