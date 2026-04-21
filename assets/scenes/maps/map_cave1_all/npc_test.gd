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
	#move_pattern()
	
	if can_talk:
		bella.text_to_send = text_to_send
		
		if Input.is_action_just_pressed("ui_accept"):
			start_now.emit()
			can_talk = false

enum enum_move {
	STILL,
	MOVE_UP,
	MOVE_DOWN,
	MOVE_LEFT,
	MOVE_RIGHT,
}

var move_array: Array = [
	enum_move.STILL,
	enum_move.MOVE_LEFT,
	enum_move.MOVE_RIGHT,
]

#var move_state: int = 0
#var move_length: float = 10.0
#var move_time: float = 0.5
#var move_delay: float = 15.0
#
#func move_pattern():
	#var tween = create_tween()
		#
	#change_move_states()
	#
	#print("move_state == " + str(move_state) + '\n')
#
	#match move_array[move_state]:
		#enum_move.STILL:
			#pass
		#enum_move.MOVE_UP:
			#tween.tween_property(self, 'position', Vector2(0, -move_length), move_time)
		#enum_move.MOVE_DOWN:
			#tween.tween_property(self, 'position', Vector2(0, move_length), move_time)
		#enum_move.MOVE_LEFT:
			#tween.tween_property(self, 'position', Vector2(-move_length, 0), move_time)
		#enum_move.MOVE_RIGHT:
			#tween.tween_property(self, 'position', Vector2(move_length, 0), move_time)
#
#func change_move_states():
	#$Timer.start(move_delay)
	#
	#if move_state < move_array.size() - 1:
		#move_state += 1
		#await $Timer.timeout
	#else:
		#move_state = 0

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = true
		
	entered_area.emit()

func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = false
		
	exited_area.emit()
