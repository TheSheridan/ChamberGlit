# TODO: Make functions for this crap.
extends Area2D


## Teleport Bella to another scene in the map. If empty, doesn't happen. 
@export_file var warp_scene = "<null>"
## The position helper in which Bella will teleport.
@export var warp_helper: String

@onready var _load = get_node("/root/auto_load")
@onready var bella = $'../../CharacterBella'


func _ready() -> void:
	body_entered.connect(_on_body_entered.bind())
	
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

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if warp_scene == "<null>":
			warp_to_pos()
		else:
			warp_to_scene()
