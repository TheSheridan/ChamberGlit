extends CharacterBody2D


var state: int
enum state_enum { QUIET, MOVE, REST }

## The battle in which the enemy belongs to.
@export_file var battle: String
## Defines how fast the enemy will chase Bella.
@export var chase_mult: float = 400
## Defines how long the invincibility state will take after battle.
@export var invincibility_duration: float = 1.5

@onready var bella = get_parent().get_node("CharacterBella")
@onready var bella_anim = get_parent().get_node("CharacterBella/AnimationPlayer")
@onready var bgm = get_parent().get_node("BGM")

@onready var _sgt = get_node("/root/auto_singleton")
@onready var _load = get_node("/root/auto_load")
@onready var _loading = get_node('/root/n_animLoading')


func _ready() -> void:
	state = state_enum.MOVE
	print(bella)
	
	if _sgt.flag_scene_changed_after_battle:
		invincibility_after_battle()
		
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

func invincibility_after_battle():
	$Collision.disabled = true

	
	state = state_enum.QUIET
	$AnimationPlayer.play("noclip")
	
	var timer = get_tree().create_timer(invincibility_duration)
	await timer.timeout
	
	_sgt.flag_scene_changed_after_battle = false
	state = state_enum.MOVE
	$Collision.disabled = false
	$SoundInvincibility.play()
	$AnimationPlayer.play("noclip_end")

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		create_tween().tween_property(bgm, 'volume_db', -50, 0.5)
		bella_anim.play("cam_woosh")
		state = state_enum.QUIET
		_sgt.fade_to_battle(bella, _sgt.battle_test1)
