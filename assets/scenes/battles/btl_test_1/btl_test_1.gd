extends Node3D


@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")
@onready var _load = get_node("/root/auto_load")

@onready var textbox = $UI/Text
@onready var textbox_bg = $UI/Color

@export var custom_volume_db: float = -2

@export var sphere_rotation = 50
var sphere_rotation_in_defeat = 0.1

var textbox_displacement = 10

var is_your_turn: bool = false
var text_order: Array = []

var dialog_start_end: Array = [
	"¡Un X te ha emboscado!",
]

var anim_arrow_move: float = 20
var anim_arrow_tween: Tween = null

# Stats
@export var bella_stats: Dictionary = {
	"hp"  : 20,
	"hp_max"  : 20,

	"pp"  : 40,
	"pp_max"  : 40,

	"level"  : 1,
	"exp": 0,
	
	"strength" : 7,
	"defense" : 5,
	"agility" : 10,
	"wisdom" : 8,
	"power" : 9,
}

@export var enemy_stats: Dictionary = {
	"hp"  : 20,
	"hp_max"  : 20,

	"pp"  : 40,
	"pp_max"  : 40,

	"strength" : 7,
	"defense" : 5,
	"agility" : 10,
	"wisdom" : 8,
	"power" : 9,
	
	"give_exp": 5,
}

var player_initiative: int = 0
var enemy_initiative: int = 0

# Text
@export var text_combat: Dictionary = {
	"start": "Ese patán de Trevor está molestándote de nuevo.",
	"your_turn": "¿Qué harás ahora?",
	"your_attack": "Lanzas un puñetazo.",
	"enemy_attack": "El enemigo te golpea.",
	
	"big_damage": "Eso tuvo que doler.",
	
	"tense": "¡Tu cuerpo se tensa! Aunque sigues sintiéndote un poco ligera.",
	
	"enemy_defeated": "[tornado radius=2 freq=5]¡Eureka! Has ganado esta batalla.[/tornado]",
	"gained_exp": "Ganas ",
	"gained_exp_2": " puntos de experiencia.",
	
	"player_defeated": "[shake rate=5]Oh... no...",
	
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

var in_a_turn: bool = false
@export var turn_delay: float = 0.25

var player_defeated_lock: bool = false
var win_switch: bool = false

@onready var rng = RandomNumberGenerator.new()


func _ready() -> void:
	_fade.show()
	_fade.color = Color.WHITE
	_fade._out.emit()
	
	#print("fairmath: " + str(_sgt.fairmath(20, 5)))
	
	set_enemy_stats()

	$BGM.volume_db = -25
	if custom_volume_db != 0:
		create_tween().tween_property($BGM, 'volume_db', custom_volume_db, 0.5)

	textbox.position += Vector2(textbox_displacement, textbox_displacement)
	textbox.text = text_combat.start
	#textbox.text = text_combat.enemy_defeated

	textbox_bg.size = textbox.size
	
	var sprite_size = $UI/Sprite2D.texture.get_size()
	$UI/Sprite2D.position = $UI/Text.size - (sprite_size * 2)
	$UI/Sprite2D.offset = sprite_size / 2
	
	$Player.billboard = true
	$Player.modulate = Color($Player.modulate, 0)
	
	$UI/VBoxContainer.modulate.a = 0
	
	$Battler.position = Vector3(0, 0, -0.8)	
	
@onready var sphere_rotation_temporal = sphere_rotation
@onready var camera_prev_offset = $Camera.position

func _process(delta: float) -> void:
	$UI/DebugLabel.text = "debug stats:\nPS: " + str(bella_stats.hp) \
		+ "\nPP: " + str(bella_stats.pp) \
		+ "\n\n-enemigo-\nPS: " + str(enemy_stats.hp) \
		+ "\nPP: " + str(enemy_stats.pp)
	
	
	$BG.rotation_degrees.y += sphere_rotation * delta
	$BG.rotation_degrees.z += sphere_rotation * delta
	
	#print(sphere_rotation)
	
	#smooth_camera()
	 
	if bella_stats.hp > 0:
		if bella_stats.hp < bella_stats.hp_max / 4:
			sphere_rotation = sphere_rotation_temporal * 5
			create_tween().tween_property($BG, "material:albedo_color", Color(0.699, 0.53, 0.53, 0.259), 0.2)
		else:
			if $BG.material.albedo_color != Color.WHITE:
				create_tween().tween_property($BG, "material:albedo_color", Color(1.0, 1.0, 1.0, 0.0), 0.1)
				
	elif bella_stats.hp <= 0:
		sphere_rotation = sphere_rotation_temporal

	if Input.is_action_just_pressed('ui_accept') and not in_a_turn:
		if bella_stats.hp > 0 \
		and !is_your_turn and !win_switch:
			anim_move_camera_out()
			decide_turn_order()

			anim_arrow()
			
			is_your_turn = true
			textbox.text = text_combat.your_turn
			
			add_first_menu()
			anim_buttons_show(1)
			$UI/VBoxContainer/Button0.grab_focus()
				
		if bella_stats.hp <= 0:
			print("Bella check")
			bella_stats.hp = 0
			is_your_turn = false
			
			if not player_defeated_lock:
				lost_the_battle()
				
		if enemy_stats.hp <= 0:
			print("The check worked!")
			enemy_stats.hp = 0
			is_your_turn = false
			
			if not player_defeated_lock:
				won_the_battle()
				
		if win_switch:
			_fade.color = Color.BLACK
			_fade._in.emit()
			
			$Timer.start(0.5)
			await $Timer.timeout
			
			_load.change_scene(_sgt.flag_prev_scene)

func set_enemy_stats():
	pass
	#enemy_stats_2.level = enemy_stats.get("level")
	
	#enemy_stats_2.hp = enemy_stats.hp
	#enemy_stats_2.mp = enemy_stats.mp
	#
	#enemy_stats_2.max_hp = enemy_stats.max_hp
	#enemy_stats_2.max_mp = enemy_stats.max_mp
	#
	#enemy_stats_2.strength = enemy_stats.strength
	#enemy_stats_2.defense = enemy_stats.defense
	#enemy_stats_2.proficiency = enemy_stats.proficiency
	#enemy_stats_2.agility = enemy_stats.agility
	#enemy_stats_2.power = enemy_stats.power

func decide_turn_order():
	var initiative = rng.randi_range(0, 1)
	#print("Initiative: " + str(initiative))
	
	if initiative == 0:
		player_initiative = 0
		enemy_initiative = 1
	else:
		player_initiative = 1
		enemy_initiative = 0

func player_turn():
	delete_buttons()
	
	textbox.text = str(text_combat.your_attack)
	is_your_turn = false
	
	enemy_stats.hp -= (bella_stats.strength / 2) * bella_stats.level

	$UI/VBoxContainer/Button0.release_focus()
	anim_buttons_show(0)
	anim_move_camera_for_battle()
	$AnimationPlayer.play("attack")
	$AttackSound.play()
	
	in_a_turn = true
	$TurnTimer.start(turn_delay)
	await $TurnTimer.timeout
	in_a_turn = false

func enemy_turn():
	delete_buttons()
	
	sphere_rotation = sphere_rotation * 10
	create_tween() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_BACK) \
			.tween_property(self, "sphere_rotation", sphere_rotation / 10, 1)
	
	textbox.text = str(text_combat.enemy_attack)
	is_your_turn = false
	
	bella_stats.hp -= enemy_stats.strength / 2
	
	anim_buttons_show(0)
	anim_move_camera_for_battle()
	$AnimationPlayer.play("enemy_attack")
	
	#$AnimationPlayer.play("enemy_attack")
	$FleeSound.play()
	
	in_a_turn = true
	$TurnTimer.start(turn_delay)
	await $TurnTimer.timeout
	in_a_turn = false

func lost_the_battle():
	anim_player_defeated()
	textbox.text = text_combat.player_defeated
	
func won_the_battle():
	textbox.text = ""
	anim_enemy_defeated()
	
	await $BattleTimer.timeout
	bella_stats.exp += enemy_stats.give_exp
	textbox.text = text_combat.enemy_defeated + "\n" \
		+ text_combat.gained_exp + str(enemy_stats.give_exp) + text_combat.gained_exp_2
	
	win_switch = true
	
func anim_player_defeated():
	#print("Player defeated function casted.")
	anim_move_camera_for_battle()
	
	create_tween().tween_property(
		$BG, "material:albedo_color", Color(0.665, 0.184, 0.32, 1.0), 0.2)
	create_tween().tween_property(
		$Battler/Light, "color", Color.BLACK, 0.2)
	create_tween().tween_property(
		$BGM, "pitch_scale", 0.55, 1)
	create_tween().tween_property(
		self, "sphere_rotation", 0.1, 1)
	
	$Player.billboard = false
	$AnimationPlayer.play("player_defeated")
	await $AnimationPlayer.animation_finished
	
	player_defeated_lock = true
	sphere_rotation = 0.05
	
	#print("Animation finished.")
	
func anim_enemy_defeated():
	player_defeated_lock = true
	delete_buttons()
	
	anim_move_camera_for_battle()
	$AnimationPlayer.play("enemy_defeated")
	create_tween().tween_property($BGM, "volume_db", -50, 1)
	create_tween().tween_property($Camera, "offset_y", 1, 1)
	
	$BattleTimer.start(1.1)

func anim_arrow():
	$UI/Sprite2D.position.x -= anim_arrow_move
	
	anim_arrow_tween = create_tween()
	anim_arrow_tween.set_ease(Tween.EASE_OUT)
	anim_arrow_tween.set_trans(Tween.TRANS_CUBIC)
	#anim_arrow_tween.tween_property(
	#	$UI/Sprite2D, "position:x", $UI/Sprite2D.position.x - anim_arrow_move, 0.1)
	anim_arrow_tween.tween_property(
		$UI/Sprite2D, "position:x", $UI/Sprite2D.position.x + anim_arrow_move, 0.5)

func move_camera_after_wait():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property($Camera, "x_offset", 1, 0.25)

#func smooth_camera():
	#var smooth_rng = RandomNumberGenerator.new()
	#var smooth_limit = 10
	#
	#var smooth_range_x: float
	#var smooth_range_y: float
	#
	#$Camera.position = lerp(
		#$Camera.position,
		#camera_prev_offset + (Vector3(smooth_range_x, smooth_range_y, 0)),
		#0.005
	#)
	#
	#while smooth_limit != 0:
		#smooth_range_x = smooth_rng.randf_range(-smooth_limit, smooth_limit)
		#smooth_range_y = smooth_rng.randf_range(-smooth_limit, smooth_limit)
		##$SmoothTimer.start(0.1)
		##await $SmoothTimer.timeout

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
				.tween_property($Camera, "position", Vector3(0, 0.15, 1.0), 0.5)
			
func add_button(text: String, number: int, function: Callable):
	var font_milonga = load("res://assets/fonts/Milonga-Regular.ttf")
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
	#print("Attack pressed")
	
	if player_initiative == 0:
		player_turn()
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
	
	_fade.color = Color.BLACK
	
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
			
	create_tween().tween_property($BGM, "volume_db", -50, 0.5)
	
	$Timer.start($FleeSound.stream.get_length() / 2)
	await $Timer.timeout
	
	# travel back to previous scene
	get_node('/root/auto_fade')._in.emit()
	_load.change_scene(_sgt.flag_prev_scene)
	
func _on_flee_sound_finished() -> void:
	print("a")
