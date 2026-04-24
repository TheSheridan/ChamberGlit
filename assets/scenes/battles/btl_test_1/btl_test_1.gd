# TODO: Implement a turn chain.
extends Node3D


@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")
@onready var _load = get_node("/root/auto_load")

@onready var textbox = $UI/Text
@onready var textbox_bg = $UI/Color

@export var custom_volume_db: float = -2

@export var sphere_rotation = 50
var sphere_rotation_in_defeat = 0.1

@export var textbox_displacement = 5

var is_your_turn: bool = false
signal do_turn_chain

var turn_order_read: int = 0

var stat_viewer_position: Vector2
var stat_viewer_move_speed: float = 0.25
@export var stat_viewer_offset: Vector2
var loosen_stat_viewer_position: bool = false

var enemy_stat_viewer_position: Vector2
@export var enemy_stat_viewer_offset: Vector2

# Text
@export var text_combat: Dictionary = {
	"start": "Ese patán de Trevor está molestándote de nuevo.",
	"your_turn": "¿Qué harás ahora?",
	"your_attack": "Lanzas un puñetazo.",
	"enemy_attack": "El enemigo te golpea.",
	
	"big_damage": "Eso tuvo que doler.",
	
	"tense": "¡Tu cuerpo se tensa! Aunque sigues sintiéndote un poco ligera.",
	
	"enemy_defeated": "[tornado radius=1.5 freq=4]¡Eureka! Has ganado esta batalla.[/tornado]",
	"gained_exp": "Obtienes ",
	"gained_exp_2": " [code]experiencia[/code].",
	
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
	"hp"  : 10,
	"hp_max"  : 10,

	"pp"  : 40,
	"pp_max"  : 40,

	"strength" : 7,
	"defense" : 5,
	"agility" : 10,
	"wisdom" : 8,
	"power" : 9,
	
	"give_exp": 8,
}

var anim_arrow_move: float = 20
var anim_arrow_tween: Tween = null

var player_initiative: int = 0
var enemy_initiative: int = 1

var count_action_buttons_1: int = 0

var turn_order: Array
var turn_chain_ready: bool = false

var in_a_turn: bool = false
@export var turn_delay: float = 0.25

var player_defeated_lock: bool = false

var win_anim_lock: bool = false
var win_switch: bool = false
var lose_switch: bool = false

@onready var rng = RandomNumberGenerator.new()


func _ready() -> void:
	_fade.show()
	_fade.color = Color.WHITE
	_fade._out.emit()
	
	#print("fairmath: " + str(_sgt.fairmath(20, 5)))
	
	if $"../auto_fade/Timer".timeout:
		$BGM.play()
	
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
	
	stat_viewer_position = $UI/StatViewer.position
	enemy_stat_viewer_position = $UI/EnemyStatViewer.position
	
	do_turn_chain.connect(turn_chain.bind())
	
@onready var sphere_rotation_temporal = sphere_rotation
@onready var camera_prev_offset = $Camera.position

func _process(delta: float) -> void:
	#print("prev scene: " + str(_sgt.flag_prev_scene))
	
	$UI/DebugLabel.text = "debug stats:\nPS: " + str(bella_stats.hp) \
		+ "\nPP: " + str(bella_stats.pp) \
		+ "\n\n-enemigo-\nPS: " + str(enemy_stats.hp) \
		+ "\nPP: " + str(enemy_stats.pp)
	
	#print(sphere_rotation)	
	#smooth_camera()
	
	$BG.rotation_degrees.y += sphere_rotation * delta
	$BG.rotation_degrees.z += sphere_rotation * delta
	 
	if bella_stats.hp > 0:
		if bella_stats.hp < bella_stats.hp_max / 4:
			sphere_rotation = sphere_rotation_temporal * 5
			create_tween().tween_property($BG, "material:albedo_color", Color(0.699, 0.53, 0.53, 0.259), 0.2)
		else:
			if $BG.material.albedo_color != Color.WHITE:
				create_tween().tween_property($BG, "material:albedo_color", Color(1.0, 1.0, 1.0, 0.0), 0.1)
				
	elif bella_stats.hp <= 0:
		sphere_rotation = sphere_rotation_temporal
		bella_stats.hp = 0
		
	if enemy_stats.hp <= 0:
		enemy_stats.hp = 0
		
	# Update stat viewer
	$UI/StatViewer/HPBar.max_value = bella_stats.hp_max
	
	$UI/StatViewer/HPBar.value = lerp(int($UI/StatViewer/HPBar.value), bella_stats.hp, 0.1)
	$UI/StatViewer/HPValue.text = str(bella_stats.hp) + "[font_size=8]/" + str(bella_stats.hp_max)
	
	$UI/StatViewer/PPBar.max_value = bella_stats.pp_max
	$UI/StatViewer/PPBar.value = bella_stats.pp
	$UI/StatViewer/PPValue.text = str(bella_stats.pp) + "[font_size=8]/" + str(bella_stats.pp_max)
	
	$UI/EnemyStatViewer/HPBar.value = lerp(int($UI/EnemyStatViewer/HPBar.value), enemy_stats.hp, 0.1)
	$UI/EnemyStatViewer/HPBar.max_value = enemy_stats.hp_max
	$UI/EnemyStatViewer/HPValue.text = str(enemy_stats.hp) + "[font_size=8]/" + str(enemy_stats.hp_max)
	
	if not loosen_stat_viewer_position:
		$UI/StatViewer.position = stat_viewer_position + stat_viewer_offset

	# The eponymous battle game loop
	if Input.is_action_just_pressed('ui_accept') and not in_a_turn:
		if turn_chain_ready and not win_switch:
			if not win_anim_lock:
				anim_stat_viewer_show()
				turn_chain()
				
				if enemy_stats.hp <= 0 or bella_stats.hp <= 0:
					_finish_chain()
					
				return
		else:
			if bella_stats.hp > 0 and not is_your_turn:
				if not win_switch:
					is_your_turn = true
					decide_turn_order()
					
					anim_stat_viewer_hide()
					
					anim_move_camera_out()
					anim_arrow()
					
					textbox.text = text_combat.your_turn
					
					add_first_menu()
					anim_buttons_show(1)
					$UI/VBoxContainer/Button0.grab_focus()
						
			if enemy_stats.hp <= 0:
				#print("The check worked!")
				is_your_turn = false
				
				if not player_defeated_lock:
					anim_stat_viewer_hide(0)
					create_tween().tween_property($UI/EnemyStatViewer, "modulate:a", 0, 0.25)
					won_the_battle()
			
			if bella_stats.hp <= 0:
				#print("Bella check")
				is_your_turn = false

				if not player_defeated_lock:
					create_tween().tween_property($UI/EnemyStatViewer, "modulate:a", 0, 0.25)
					lost_the_battle()
					
			if win_switch:
				after_winning()
				
			if lose_switch:
				after_losing()

func after_winning():
	_fade.color = Color.BLACK
	_fade.fade_time = 0.5
	_fade._in.emit()
	
	$BGMFightOver.stop()
	
	$Timer.start(0.5)
	await $Timer.timeout
	
	#_sgt.flag_scene_changed_after_winning = true
	_load.change_scene(_sgt.flag_prev_scene, "AfterBattle")
	
func after_losing():
	_fade.fade_time = 0.5
	_fade.color = Color.BLACK
	_fade._in.emit()
	
	create_tween() \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property($Camera, 'v_offset', 0.5, _fade.fade_time * 2)
	create_tween().tween_property($BGM, 'volume_db', -50, _fade.fade_time)
	
	$Timer.start(0.75)
	await $Timer.timeout

	_sgt.flag_scene_changed_after_winning = true
	_sgt.flag_bella_house_appear_in_bed = true
	_load.change_scene(_sgt.scene_bella_house)

func turn_chain():
	print_rich(
		"[b]turn_order:[/b]" + str(turn_order) + "\n"
		+ 'read:' + str(turn_order_read) + "\n"
		+ 'size:' + str(turn_order.size()) + "\n"
	)		
	
	if turn_order_read < turn_order.size():
		match turn_order[turn_order_read]:
			player_initiative:
				#print("1")
				player_turn()
			enemy_initiative:
				#print("2")
				enemy_turn()
			
		print_rich("[color=yellow]-> current_turn: " + str(turn_order[turn_order_read]))
		turn_order_read += 1
		
		if turn_order_read >= turn_order.size():
			_finish_chain()
	else:
		_finish_chain()
		
	if turn_order_read == 0:
		$UI/VBoxContainer/Button0.release_focus()

func _finish_chain():
	turn_chain_ready = false
	turn_order_read = 0
	turn_order.clear()
	delete_buttons()
	
	if $UI/VBoxContainer.has_node("Button0"):
		$UI/VBoxContainer/Button0.release_focus()

func decide_turn_order():
	# Prepare the turn order
	turn_order.clear()
	
	var fighter_list = [enemy_initiative, player_initiative]
	var initiative = rng.rand_weighted(fighter_list)
	
	# Decide initiative
	for i in fighter_list.size():
		turn_order.append(fighter_list[i])
	
	turn_order.erase(turn_order.bsearch(initiative))
	turn_order.push_front(initiative)
	
	turn_chain_ready = true
	
	# Debug
	#print("initiative: " + str(initiative) + "[n]turn_order:" + str(turn_order))
	return initiative

func player_turn():
	in_a_turn = true
	
	textbox.text = str(text_combat.your_attack)
	is_your_turn = false
	
	enemy_stats.hp -= (bella_stats.strength / 2) * bella_stats.level
	
	anim_buttons_show(0)
	anim_move_camera_for_battle()
	$AnimationPlayer.play("attack")
	$AttackSound.play()
	
	if bella_stats.hp <= 0 or enemy_stats.hp <= 0:
		turn_delay *= 1.1
	
	$TurnTimer.start(turn_delay)
	await $TurnTimer.timeout
	in_a_turn = false

func enemy_turn():
	in_a_turn = true
	
	sphere_rotation = sphere_rotation * 10
	
	@warning_ignore("integer_division")
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
	$UI/StatViewer/AnimationPlayer.play("shake")
	
	#$AnimationPlayer.play("enemy_attack")
	$HurtSound.play()
	
	$TurnTimer.start(turn_delay)
	await $TurnTimer.timeout
	in_a_turn = false

func lost_the_battle():
	anim_player_defeated()
	textbox.text = text_combat.player_defeated
	
func won_the_battle():
	win_anim_lock = true
	textbox.text = ""
	
	
	$BGMFightOver.play()
	create_tween().tween_property($BGMFightOver, 'volume_db', 1, 0.5)
	anim_enemy_defeated()
	create_tween().tween_property($UI/VBoxContainer, "modulate:a", 0, 0.5)
	create_tween().set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property($Camera, "position", Vector3(0, 0.4, 1), 1)
	await $BattleTimer.timeout
	
	win_anim_lock = false
	win_switch = true
	bella_stats.exp += enemy_stats.give_exp
	textbox.text = text_combat.enemy_defeated + '\n' \
			+ text_combat.gained_exp + '[b]' + str(enemy_stats.give_exp) + '[/b]' \
			+ text_combat.gained_exp_2
	
func anim_player_defeated():
	#print("Player defeated function casted.")
	anim_move_camera_for_battle()
	
	create_tween().tween_property(
		$BG, "material:albedo_color", Color(0.665, 0.184, 0.32, 1.0), 0.2)
	create_tween().tween_property(
		$Battler/Light, "color", Color.BLACK, 0.2)
	create_tween().tween_property(
		$BGM, "pitch_scale", 0.50, 1)
	create_tween().tween_property(
		self, "sphere_rotation", 0.1, 1)
	
	$Player.billboard = false
	$AnimationPlayer.play("player_defeated")
	await $AnimationPlayer.animation_finished
	
	player_defeated_lock = true
	sphere_rotation = 0.05
	
	lose_switch = true
	
	#print("Animation finished.")
	
func anim_enemy_defeated():
	player_defeated_lock = true
	delete_buttons()
	
	$AnimationPlayer.play("enemy_defeated")
	create_tween().tween_property($BGM, "volume_db", -50, 1)
	create_tween().tween_property($Camera, "offset_y", 1, 1)
	
	$BattleTimer.start(1.1)

func anim_arrow():
	$UI/Sprite2D.position.x -= anim_arrow_move
	
	anim_arrow_tween = create_tween()
	anim_arrow_tween.set_ease(Tween.EASE_OUT)
	anim_arrow_tween.set_trans(Tween.TRANS_CUBIC)
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
		
func anim_stat_viewer_show(value: float = 1.0, which_one: Node = $UI/StatViewer):
	loosen_stat_viewer_position = false
	create_tween().tween_property(which_one, "modulate:a", value, stat_viewer_move_speed)
	var tween = create_tween() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property(which_one, "position:x", stat_viewer_position.x, stat_viewer_move_speed)
	await tween.finished
	loosen_stat_viewer_position = true
	$UI/StatViewer/AnimationPlayer.stop()

# ...yes, has almost the same code as the one at the top ._.
func anim_stat_viewer_hide(value: float = 0.5, which_one: Node = $UI/StatViewer):
	loosen_stat_viewer_position = false
	create_tween().tween_property(which_one, "modulate:a", value, stat_viewer_move_speed)
	var tween = create_tween() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property(which_one, "position:x", stat_viewer_position.x - 50, stat_viewer_move_speed)
	await tween.finished
	loosen_stat_viewer_position = true
	$UI/StatViewer/AnimationPlayer.stop()
			
func add_button(text: String, number: int, function: Callable):
	var font_milonga = load("res://assets/fonts/Milonga-Regular.ttf")
	#var font_long = load("res://assets/fonts/RG2014F.ttf")
	
	var button = Button.new()
	button.text = text
	button.add_theme_font_override("font", font_milonga)
	button.add_theme_font_size_override("font_size", 30)
	button.add_to_group("battle_buttons")
	button.pressed.connect(function)
	
	button.name = "Button" + str(number)
	
	$UI/VBoxContainer.add_child(button)
	
func delete_buttons():
	for i in text_action_buttons_1.size():
		if get_tree().get_nodes_in_group("battle_buttons") and not win_anim_lock:
			get_node("UI/VBoxContainer/Button" + str(i)).queue_free()

func add_first_menu():
	for i in text_action_buttons_1.size():
		add_button(text_action_buttons_1[i], i, Callable(self, "button_action_" + str(i)))

func button_action_0():
	if not turn_chain_ready:
		decide_turn_order()
		
	#do_turn_chain.emit()
	return
	
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
	
	_sgt.flag_scene_changed_after_winning = true
	
	# travel back to previous scene
	get_node('/root/auto_fade')._in.emit()
	_load.change_scene(_sgt.flag_prev_scene, "AfterBattle")
	
func _on_flee_sound_finished() -> void:
	print("a")
