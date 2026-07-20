extends CharacterBody3D


@onready var original_place = position

var state: int
enum state_enum { QUIET, MOVE, REST, GO_BACK }

var going_back: bool

## The battle in which the enemy belongs to.
@export_file var battle: String
## Defines how fast the enemy will chase Bella.
@export var chase_speed: float = 3.0
@export var go_back_speed: float = 2.0
@export var go_back_wait_duration: float = 5.0
## Defines how long the invincibility state will take after battle.
@export var invincibility_duration: float = 1.5

@onready var bella = $"../../CharacterBella3D"
@onready var bella_anim = $"../../CharacterBella3D/AnimationPlayer"
@onready var bgm = $"../../BGM"

@onready var _sgt = $"/root/auto_singleton"
@onready var _load = $"/root/auto_load"
@onready var _loading = $"/root/n_animLoading"
@onready var _bgm = $"/root/bgm"


func _ready() -> void:
	state = state_enum.QUIET
	print(bella)
	
	if _sgt.flag_scene_changed_after_battle:
		invincibility_after_battle()
		
func _process(delta: float) -> void:
	var chase_distance = position.distance_to(bella.position)
	var chase_vector = position.move_toward(bella.position, chase_speed * delta)
	var original_place_vector = position.move_toward(original_place, go_back_speed * delta)
	var friction: float = 0.8
	
	match state:
		state_enum.QUIET:
			pass
		state_enum.MOVE:
			print(chase_vector)
			position = lerp(position, chase_vector, friction)
		state_enum.GO_BACK:
			if not position == original_place:
				going_back = true
				position = lerp(position, original_place_vector, friction)
				
				if position == original_place:
					state = state_enum.QUIET
					going_back = false

func invincibility_after_battle():
	$Collision.disabled = true
	state = state_enum.REST
	$AnimationPlayer.play("noclip")
	
	var timer = get_tree().create_timer(invincibility_duration)
	await timer.timeout
	
	_sgt.flag_scene_changed_after_battle = false
	state = state_enum.MOVE
	$Collision.disabled = false
	$SoundInvincibility.play()
	$AnimationPlayer.play("noclip_end")

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and state != state_enum.REST:
		_bgm.fade_out()
		_bgm.fade_out_bg()
		bella_anim.play("cam_woosh")
		state = state_enum.QUIET
		_sgt.fade_to_battle(bella, battle, true)

func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = state_enum.MOVE

func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = state_enum.REST
		$Timer.start(go_back_wait_duration)

func _on_timer_timeout() -> void:
	state = state_enum.GO_BACK
