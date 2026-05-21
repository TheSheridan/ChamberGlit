extends Node2D

@onready var _sgt = $/root/auto_singleton

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon
@onready var balloon_fade = $CharacterBella/ExampleBalloon/FadeAnim

var minotaur_first_question: bool = true
## Dialog related. If the Minotaur said what's an artifact, be able
## for Bella to ask question 4.
var can_ask_minotaur_q4: bool = false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	bella._fade_out.emit()
	
	# DEBUG
	#_sgt.flag_minotaur_beated = true

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)

func fade_volume(easing, time):
	var vol: float
	
	match easing:
		false:
			vol = -50.0
		true:
			vol = 0.0
		
	create_tween().tween_property($BGM, 'volume_db', vol, time)

func move_m():
	$M/AnimationPlayer.play("move")
	
signal move_m_fight_finished
func move_m_fight():
	var prev_fade_duration = bella.fade_duration
	
	bella.stand_still = true
	bella.fade_color = Color.WHITE
	bella.fade_duration = 0.6
	bella._fade_in.emit()
	
	$M/AnimationPlayer.play("fight")
	await $M/AnimationPlayer.animation_finished
	
	bella.fade_duration = prev_fade_duration
	bella._fade_out.emit()

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass

func _on_actionable_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		bella.stand_still = true
		$Deadend/Actionable2D.dialogue_resource = $Deadend.text_to_send
		$Deadend/Actionable2D.actioned.emit()
