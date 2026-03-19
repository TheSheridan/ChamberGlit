extends CharacterBody2D


@export var text_to_send: Array = [
	"Test text.",
]

@onready var bella = get_parent().get_node("CharacterBella")

var can_talk: bool = false
signal start_now


func _process(_delta) -> void:
	if can_talk:
		bella.text_to_send = text_to_send
		
		if Input.is_action_just_pressed("ui_accept"):
			start_now.emit()
			can_talk = false

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = true


func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = false
