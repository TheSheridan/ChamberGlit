# TODO: Make functions for this crap.
extends Area2D


@onready var _load = get_node("/root/auto_load")
@onready var _loading = $'/root/n_animLoading'
@onready var _bgm = $"/root/bgm"

## Teleport Bella to another scene in the map. If empty, doesn't happen. 
@export_file var warp_scene = "<null>"
## The position helper in which Bella will teleport.
@export var warp_helper: String

@onready var bella = $'../../CharacterBella'

@export var zoom_camera: bool = false
@export_enum("In", "Out") var zoom_ease: int = false
var zoom_how_much: float
var zoom_tween: Tween
@onready var zoom_time: float = bella.fade_duration

## Fades the BGM, Captain Obvious. Turn it off if you need to play it for more than one scene
@export var fade_bgm: bool = true
@export_enum("Dark", "Light") var loading_color = 1

signal warp_finished

func _ready() -> void:
	body_entered.connect(_on_body_entered.bind())
	warp_finished.connect(_on_warp_finished.bind())

func warp_to_pos():
	var helper = get_node("../../PositionHelpers/" + warp_helper) 
	
	bella.fade_in()
	
	var timer = get_tree().create_timer(bella.fade_duration)
	await timer.timeout
	
	bella.position = helper.position
	bella.fade_out()
	warp_finished.emit()
	
func warp_to_scene():
	bella.fade_in()
	
	var timer = get_tree().create_timer(bella.fade_duration)
	await timer.timeout
	
	_load.change_scene(warp_scene, warp_helper)
	warp_finished.emit()
	
func zoom():
	var time: float
	
	if zoom_ease:
		zoom_how_much = 2
		time = zoom_time * 2
	else:
		zoom_how_much = 0.5
		time = zoom_time * 2
	
	zoom_tween = create_tween()
	zoom_tween.set_ease(Tween.EASE_IN_OUT)
	zoom_tween.set_trans(Tween.TRANS_CUBIC)

	zoom_tween.tween_property(bella, 'camera_zoom', zoom_how_much, zoom_time)
	
	await zoom_tween.finished
	zoom_tween = null

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_loading.sprite_color = loading_color
		
		if fade_bgm:
			_bgm.fade_out()
		
		if zoom_camera:
			zoom()
		
		if warp_scene != "<null>":
			warp_to_scene()
			_loading._out.emit()
		else:
			warp_to_pos()
			

func _on_warp_finished():
	pass
