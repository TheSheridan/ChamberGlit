extends CharacterBody2D


var state: int
enum state_enum { QUIET, MOVE, REST }

@export_file var battle: String
@export var chase_mult: float = 400

@onready var bella = get_parent().get_node("CharacterBella")
@onready var bgm = get_parent().get_node("BGM")

@onready var _sgt = get_node("/root/auto_singleton")
@onready var _load = get_node("/root/auto_load")
@onready var _loading = get_node('/root/n_animLoading')


func _ready() -> void:
	state = state_enum.MOVE
	print(bella)
	
	
func _process(delta: float) -> void:
	var chase_distance = position.distance_to(bella.position)
	var chase_vector = position.move_toward(bella.position, delta * chase_mult)
	
	if chase_distance < 300.0:
		match state:
			state_enum.QUIET:
				pass
			state_enum.MOVE:
				print(chase_vector)
				position = lerp(position, chase_vector, 0.8)


func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		create_tween().tween_property(bgm, 'volume_db', -50, 0.5)
		state = state_enum.QUIET
		_sgt.fade_to_battle(bella, _sgt.battle_test1)
