extends CharacterBody2D


@onready var _load = get_node("/root/auto_load")
@onready var _sgt = get_node("/root/auto_singleton")

@export var text_to_send: Array = [
	"Test text.",
]

@onready var bella = get_parent().get_node("CharacterBella")

var can_talk: bool = false
var can_battle: bool = false

signal entered_area
signal exited_area
signal start_now


func _ready():
	print("This scene path: " + str(get_node(".").get_path()))
	
	var bella = get_node("../CharacterBella")
	
	entered_area.connect(bella.entered_area.bind())
	exited_area.connect(bella.exited_area.bind())
	start_now.connect(bella.npc_start_now.bind())
	
	bella.let_stuff_after_textbox.connect(after_textbox.bind())

func _process(_delta) -> void:
	print("Can battle? " + str(can_battle))
	
	if can_talk:
		bella.text_to_send = text_to_send
		
		if Input.is_action_just_pressed("ui_accept"):
			start_now.emit()
			can_talk = false


func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = true
		can_battle = true
		
	entered_area.emit()

func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_talk = false
		can_battle = false
		
	exited_area.emit()
	
func after_textbox():
	if can_battle:
		_sgt.quick_prev(_sgt.scene_vespera_village, $"../CharacterBella".position)
		_sgt.flag_use_prev_position_in_scene = true
		_load.change_scene(_sgt.battle_test1)
