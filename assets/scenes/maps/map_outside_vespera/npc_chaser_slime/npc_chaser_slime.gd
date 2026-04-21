extends CharacterBody2D


var state: int
enum state_enum { QUIET, MOVE, REST }

@export var chase_mult: float = 400

@onready var bella = get_parent().get_node("CharacterBella")
@onready var _sgt = get_node("/root/auto_singleton")
@onready var _load = get_node("/root/auto_load")


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
		_sgt.quick_prev(_sgt.scene_outside_vespera, bella.position)
		$SoundBattle.play()
		state = state_enum.QUIET
		
		create_tween().set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_CUBIC) \
				.tween_property(bella, "camera_zoom", 5.0, 0.5)
				
		$Timer.start(1)
		await $Timer.timeout
		
		bella.fade_color = Color.WHITE
		bella._fade_in.emit()
		
		$Timer.start(bella.fade_duration)
		await $Timer.timeout
				
		_load.change_scene(_sgt.battle_test1)
		
