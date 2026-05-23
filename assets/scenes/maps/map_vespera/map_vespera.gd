extends Node2D


@onready var _sgt = $/root/auto_singleton
@onready var _load = $/root/auto_load

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

var npc_battle_enter: bool
var show_sigi_signal: bool = false

var name_ruth: String = "[color=green]Ruth:[/color]"

func _ready() -> void:
	# Debug
	_sgt.flag_minotaur_beated = true
	
	RenderingServer.set_default_clear_color(Color(0.653, 0.693, 0.714, 1.0))
	bella._fade_out.emit()
	_sgt.check_bella_position(bella, name)
	
	print("helper: " + str(_sgt.flag_helper))
	
	if _sgt.flag_minotaur_beated:
		#$Ruth.position = Vector2(-841, -1229)
		$Ruth/Anim.play("post_boss1_move")
		$Sigi/Anim.play("post_boss1_move")
	else:
		$Sigi.hide()
		
	# NPC coloring crap bc I'm a sucker for overcomplicating my life
	$Ruth.modulate = Color.GREEN_YELLOW
	$Sigi.modulate = Color.ORANGE

func _process(delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)

func ruth_anim(id: String):
	$Ruth/Anim.play(id)
	
var sigi_move_mult: float = 400
func show_sigi():
	$Sigi.show()
	#var move_vector = $Sigi.position.move_toward($CharacterBella.position, delta * sigi_move_mult)
	#position = lerp(position, move_vector, 0.8)
	#$Sigi.position = $CharacterBella.position + Vector2(40, 0)
	$Sigi/Anim.play("come_in")

func fade_audio():
	create_tween().tween_property($BGM, "volume_db", 0, 0.5)

func _on_npc_battle_finished() -> void:
	_sgt.quick_prev(_sgt.scene_vespera, bella.position)
		
	bella.can_talk = false
	bella.fade_color = Color.WHITE
	bella._fade_in.emit()
	
	var timer = get_tree().create_timer(bella.fade_duration)
	await timer.timeout
	
	_load.change_scene(_sgt.battle_test1)
