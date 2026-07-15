extends Area3D


## Teleport Bella to another scene in the map. If empty, doesn't happen. 
@export_file var warp_scene = "<null>"
## The position helper in which Bella will teleport.
@export var warp_helper: String
@export var zoom_camera: bool = false
@export_enum("In", "Out") var zoom_ease: int = false

var zoom_how_much: float
var zoom_tween: Tween

@onready var bella = $'../../CharacterBella3D'
@onready var bella_cam = $'../../CharacterBella3D/Camera3D'
@onready var zoom_time = bella.fade_duration

@onready var _load = get_node("/root/auto_load")
@onready var _loading = $'/root/n_animLoading'


func warp_to_pos():
	var helper = get_node("../../PositionHelpers/" + warp_helper) 
	
	bella.fade_in()
	
	var timer = get_tree().create_timer(bella.fade_duration)
	await timer.timeout
	
	bella.position = helper.position
	bella.fade_out()
	
func warp_to_scene():
	bella.fade_in()
	
	var timer = get_tree().create_timer(bella.fade_duration)
	await timer.timeout
	
	_load.change_scene(warp_scene, warp_helper)
	
func zoom():
	var time: float = 0.5
	
	if zoom_ease:
		zoom_how_much = 1
		time = zoom_time
	else:
		zoom_how_much = 2
		time = zoom_time
	
	zoom_tween = create_tween()
	zoom_tween.set_ease(Tween.EASE_IN_OUT)
	zoom_tween.set_trans(Tween.TRANS_CUBIC)

	zoom_tween.tween_property(bella_cam, 'position', Vector3(0, 0, zoom_how_much), zoom_time)
	
	await zoom_tween.finished
	zoom_tween = null

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Player entered.")
		
		if zoom_camera:
			zoom()
		
		if warp_scene != "<null>":
			warp_to_scene()
			_loading._out.emit()
		else:
			warp_to_pos()
			
