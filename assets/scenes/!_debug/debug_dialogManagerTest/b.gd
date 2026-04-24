extends Node2D


@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon
var can_talk: bool = false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.DARK_GRAY)
	bella._fade_out.emit()

func _process(_delta) -> void:
	print("can_talk == " + str(can_talk))
	
	if can_talk:
		handle_dialog()
	
func handle_dialog():
	if Input.is_action_just_pressed("ui_accept"):
		if not balloon.after_closing:
			if not balloon.is_running_dialog:
				bella.stand_still = true
				bella.npc_start_now()
		else:
			bella.stand_still = false
			balloon.after_closing = false

func _on_actionable_2d_actioned() -> void:
	balloon.start()


func _on_actionable_2d_body_entered(body: Node2D) -> void:
	bella.text_to_send = $Chest.text_to_send
	
	if body.is_in_group("player"):
		print("qshweouhoi")
		can_talk = true

func _on_actionable_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		can_talk = false
