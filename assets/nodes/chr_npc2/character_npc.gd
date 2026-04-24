extends CharacterBody2D


@export var text_to_send: DialogueResource
@export var cue: String
signal finished

@onready var bella = get_parent().get_node("CharacterBella")
@onready var balloon = get_parent().get_node("CharacterBella/ExampleBalloon")
@onready var action = $Actionable2D

signal entered_area
signal exited_area
signal start_now


func _ready() -> void:
	action.dialogue_resource = text_to_send
	action.dialogue_cue = cue
	
	action.dialogue_ended.connect(_on_actionable_2d_dialogue_ended.bind())
	action.body_entered.connect(_on_area_body_entered.bind())
	action.body_exited.connect(_on_area_body_exited.bind())

func _process(_delta) -> void:
	if bella.can_talk:
		bella.text_to_send = text_to_send
		
		if Input.is_action_just_pressed("ui_accept"):
			start_now.emit()
			
	#move_pattern()

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("Entered")
		bella.can_talk = true
		balloon.dialogue_resource = text_to_send
		
	entered_area.emit()

func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("Exited")
		bella.can_talk = false
		balloon.dialogue_resource = null
		
	exited_area.emit()

func _on_actionable_2d_dialogue_ended() -> void:
	bella.stand_still = false
	finished.emit()
