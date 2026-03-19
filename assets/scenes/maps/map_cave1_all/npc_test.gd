extends CharacterBody2D


@export var text_to_send: Array = [
	"Test text.",
]

@onready var bella = get_parent().get_node("CharacterBella")

var can_talk: bool = false

signal entered_area
signal exited_area
signal start_now


func _ready():
	var bella = get_node("../CharacterBella")
	
	entered_area.connect(bella.entered_area.bind())
	exited_area.connect(bella.exited_area.bind())
	start_now.connect(bella.npc_start_now.bind())

func _process(_delta) -> void:
	if can_talk:
		bella.text_to_send = text_to_send
		
		if Input.is_action_just_pressed("ui_accept"):
			start_now.emit()
			can_talk = false

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = true
		
	entered_area.emit()


func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = false
		
	exited_area.emit()
