extends CharacterBody3D


@export var text_to_send: DialogueResource
@export var cue: String
signal finished

@onready var bella = $"../CharacterBella3D"
@onready var balloon = $"../CharacterBella3D/ExampleBalloon"
@onready var action = $Actionable3D

@onready var _loading = $"/root/n_animLoading"

signal entered_area
signal exited_area
signal start_now


func _ready() -> void:
	action.dialogue_resource = text_to_send
	action.dialogue_cue = cue
	
	action.dialogue_ended.connect(_on_actionable_3d_dialogue_ended.bind())
	action.body_entered.connect(_on_area_body_entered.bind())
	action.body_exited.connect(_on_area_body_exited.bind())
	
	start_now.connect(open_balloon.bind())

func _process(_delta) -> void:
	if bella.can_talk:
		bella.text_to_send = text_to_send
		#print("Text sended. ("+ str(bella.text_to_send) + " == " + str(text_to_send) + ")")
		
		if Input.is_action_just_pressed("ui_accept"):
			start_now.emit()
			
		if balloon.after_closing:
			bella.stand_still = false
			
	#move_pattern()

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		#print("Entered")
		bella.can_talk = true
		balloon.dialogue_resource = text_to_send
		
	entered_area.emit()

func _on_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		#print("Exited")
		bella.can_talk = false
		balloon.dialogue_resource = null
		
	exited_area.emit()

func _on_actionable_3d_dialogue_ended() -> void:
	bella.stand_still = false
	finished.emit()
	_loading.sprite_color = false

func open_balloon():
	bella.stand_still = true
	
	if not balloon.is_running_dialog:
		bella.npc_start_now()
