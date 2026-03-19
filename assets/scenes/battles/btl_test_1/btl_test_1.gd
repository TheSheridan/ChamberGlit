extends Node3D


@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")
@onready var _load = get_node("/root/auto_load")

@onready var textbox = $UI/Text
@onready var textbox_bg = $UI/Color

@export var sphere_rotation = 50
var textbox_displacement = 10

var is_your_turn: bool = false
var text_order: Array = []

var dialog_start_end: Array = [
	"¡Un X te ha emboscado!",
]

var anim_arrow_move: float = 20
var anim_arrow_tween: Tween = null

# Stats
var player_stats: Dictionary = {
	"hp"  : 20,
	"hp_max"  : 20,

	"pp"  : 40,
	"pp_max"  : 40,

	"level"  : 1,
	
	"strength" : 0,
	"speed" : 0,
	"intelligence" : 0,
}

var enemy_stats: Dictionary = {
	"hp"  : 20,
	"hp_max"  : 20,

	"pp"  : 40,
	"pp_max"  : 40,

	"strength" : 0,
	"speed" : 0,
	"intelligence" : 0,
}

var player_initiative: int = 0
var enemy_initiative: int = 0

# Text
var text_combat: Dictionary = {
	"start": "¡Te ha emboscado un monstruo!",
	"your_turn": "¿Qué harás ahora?",
	"your_attack": "Lanzas un puñetazo.",
	"enemy_attack": "El enemigo te golpea.",
	
	"big_damage": "Eso tuvo que doler.",
	
	"tense": "Tu cuerpo se tensa, pero sigues sintiéndote ligera.",
	
	"flee": "Mejor irse de aquí."
}

var text_action_buttons_1: Array = [
	"Atacar",
	"Hablar",
	"Magias",
	"Mochila",
	"Huir",
]
var count_action_buttons_1: int = 0

@onready var rng = RandomNumberGenerator.new()


func _ready() -> void:
	_fade._out.emit()
	create_tween().tween_property($bgm, 'volume_db', 0, 0.5)

	textbox.position += Vector2(textbox_displacement, textbox_displacement)
	textbox.text = text_combat.start

	textbox_bg.size = textbox.size
	
	var sprite_size = $UI/Sprite2D.texture.get_size()
	$UI/Sprite2D.position = $UI/Text.size - (sprite_size * 2)
	$UI/Sprite2D.offset = sprite_size / 2
	
	$Player.modulate = Color($Player.modulate, 0)
	$UI/VBoxContainer.modulate.a = 0
	
	$Battler.position = Vector3(0, 0, -0.8)
	
func _process(delta: float) -> void:
	$UI/DebugLabel.text = "stats de depuración:\nPS: " + str(player_stats.hp) \
		+ "\nPP: " + str(player_stats.pp) \
		+ "\n\n-enemigo-\nPS: " + str(enemy_stats.hp) \
		+ "\nPP: " + str(enemy_stats.pp)
	
	$BG.rotation_degrees.y += sphere_rotation * delta
	$BG.rotation_degrees.z += sphere_rotation * delta

	if Input.is_action_just_pressed('ui_accept'):
		anim_move_camera_out()
		
		if !is_your_turn:
			decide_turn_order()

			anim_arrow()
			
			is_your_turn = true
			textbox.text = text_combat.your_turn
			
			add_first_menu()
			anim_buttons_show(1)
			$UI/VBoxContainer/Button0.grab_focus()

func decide_turn_order():
	var initiative = rng.randf_range(0, 1)
	
	if initiative == 0:
		player_initiative = 0
		enemy_initiative = 1
	else:
		player_initiative = 1
		enemy_initiative = 0

func enemy_turn():
	delete_buttons()
	
	textbox.text = str(text_combat.enemy_attack)
	is_your_turn = false
	
	player_stats.hp -= 1
	
	#$AnimationPlayer.play("enemy_attack")
	$AttackSound.play()
	

func anim_arrow():
	$UI/Sprite2D.position.x -= anim_arrow_move
	
	anim_arrow_tween = create_tween()
	anim_arrow_tween.set_ease(Tween.EASE_OUT)
	anim_arrow_tween.set_trans(Tween.TRANS_CUBIC)
	#anim_arrow_tween.tween_property(
	#	$UI/Sprite2D, "position:x", $UI/Sprite2D.position.x - anim_arrow_move, 0.1)
	anim_arrow_tween.tween_property(
		$UI/Sprite2D, "position:x", $UI/Sprite2D.position.x + anim_arrow_move, 0.5)

# TODO: Move this tweens to a variable and edit them there.
func anim_buttons_show(alpha: float):
	create_tween().set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property(
				$UI/VBoxContainer, "modulate:a", alpha, 0.1)

func anim_move_camera_out():
	create_tween().set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_CUBIC) \
				.tween_property($Camera, "position", Vector3(0.15, 0.1, 0.4), 0.5)
				
	create_tween().set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_CUBIC) \
				.tween_property($Player, "modulate", Color($Player.modulate, 1), 0.5)

func anim_move_camera_for_battle():
	create_tween().set_ease(Tween.EASE_IN_OUT) \
				.set_trans(Tween.TRANS_CUBIC) \
				.tween_property($Player, "modulate", Color($Player.modulate, 1), 0.5)
	
	create_tween().set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_CUBIC) \
				.tween_property($Camera, "position", Vector3(0, 0.15, 0.6), 0.5)
			
func add_button(text: String, number: int, function: Callable):
	var font_milonga = load("res://assets/fonts/Ubuntu-Regular.ttf")
	var font_long = load("res://assets/fonts/RG2014F.ttf")
	
	var button = Button.new()
	button.text = text
	button.add_theme_font_override("font", font_milonga)
	button.add_theme_font_size_override("font_size", 30)
	
	button.pressed.connect(function)
	
	button.name = "Button" + str(number)
	
	$UI/VBoxContainer.add_child(button)
	
func delete_buttons():
	for i in text_action_buttons_1.size():
		get_node("UI/VBoxContainer/Button" + str(i)).queue_free()

func add_first_menu():
	for i in text_action_buttons_1.size():
		add_button(text_action_buttons_1[i], i, Callable(self, "button_action_" + str(i)))

# Attack
func button_action_0():
	delete_buttons()
	print("Attack pressed")
	
	if player_initiative == 0:
		textbox.text = str(text_combat.your_attack)
		is_your_turn = false
		
		enemy_stats.hp -= 1
		
		$UI/VBoxContainer/Button0.release_focus()
		anim_buttons_show(0)
		anim_move_camera_for_battle()
		$AnimationPlayer.play("attack")
		$AttackSound.play()
	else:
		enemy_turn()
	
# Talk
func button_action_1():
	print("Talk pressed")

func button_action_2():
	print("Magic pressed")

func button_action_3():
	print("Bag pressed")

func button_action_4():
	delete_buttons()
	
	textbox.text = str(text_combat.flee)
	anim_move_camera_for_battle()
	
	$AnimationPlayer.play("flee")
	
	$FleeSound.play()
	
	$Timer.start($FleeSound.stream.get_length() / 2)
	await $Timer.timeout

	create_tween() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property($UI/Fade, "modulate", Color($UI/Fade.modulate, 1), 0.5)
	$Timer.start($FleeSound.stream.get_length() / 2)
	await $Timer.timeout
	
	# travel back to previous scene
	get_node('/root/auto_fade')._in.emit()
	_load.change_scene(_sgt.flag_prev_scene)
	
func _on_flee_sound_finished() -> void:
	print("a")
