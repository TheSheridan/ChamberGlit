# TODO list:
# - Implement a turn chain.
# - Put the StatViewer animations in their Containers
extends Node3D


#region Variables
@export var custom_volume_db: float = -2

@export var sphere_rotation = 50
var sphere_rotation_in_defeat = 0.1

@export var textbox_displacement = 5

var battle_marker_size

var is_your_turn: bool = false
signal do_turn_chain

var turn_order_read: int = 0

var stat_viewer_position: Vector2
var stat_viewer_move_speed: float = 0.25
@export var stat_viewer_offset = Vector2(20, 20)
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

@onready var sphere_rotation_temporal = sphere_rotation
@onready var camera_prev_offset = $Camera.position

@onready var _sgt = get_node("/root/auto_singleton")
@onready var _fade = get_node("/root/auto_fade")
@onready var _load = get_node("/root/auto_load")
@onready var _loading = get_node('/root/n_animLoading')
@onready var _bgm = $"/root/bgm"

@onready var textbox = %Textbox
@onready var textbox_bg = $UI/BG/Sprite
@onready var BattleMarker = $UI/NextMarker
@onready var ActionBox = $UI/ActionBox

@onready var PlayerStatViewer = $UI/PlayerStatContainer/StatViewer
@onready var EnemyStatViewer = $UI/EnemyStatContainer/EnemyStatViewer

@onready var PlayerStatContainer = $UI/PlayerStatContainer
@onready var EnemyStatContainer = $UI/EnemyStatContainer

@onready var PlayerHPBar = $UI/PlayerStatContainer/StatViewer/HPBar
@onready var PlayerHPValue = $UI/PlayerStatContainer/StatViewer/HPValue
@onready var PlayerPPBar = $UI/PlayerStatContainer/StatViewer/PPBar
@onready var PlayerPPValue = $UI/PlayerStatContainer/StatViewer/PPValue

@onready var EnemyHPBar = $UI/EnemyStatContainer/EnemyStatViewer/HPBar
@onready var EnemyHPValue = $UI/EnemyStatContainer/EnemyStatViewer/HPValue

@onready var player_stat_viewer_prev_pos = PlayerStatViewer.position

#endregion


func _ready() -> void:
	_fade.show()
	_fade.color = Color.WHITE
	_fade._out.emit()
	
	#print("fairmath: " + str(_sgt.fairmath(20, 5)))

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"), 0)
	
	if $"../auto_fade/Timer".timeout:
		_bgm.play_music("bgm_fancybattle.ogg", 1, -25)
	
	_bgm.fade_in()

	textbox.position += Vector2(textbox_displacement, textbox_displacement)
	textbox.text = text_combat.start
	#textbox.text = text_combat.enemy_defeated
	
	$Player.billboard = true
	$Player.modulate = Color($Player.modulate, 0)
	
	ActionBox.modulate.a = 0
	
	$Battler.position = Vector3(0, 0, -0.8)	
	 
	#enemy_stat_viewer_offset.y += $UI/BattleLog.size.y
	
	#stat_viewer_position = $UI/PlayerStatContainer.position + stat_viewer_offset
	#enemy_stat_viewer_position = $UI/EnemyStatContainer.position + enemy_stat_viewer_offset
	
	do_turn_chain.connect(turn_chain.bind())
	
	_loading._out.emit()
	_loading.sprite_color = true
	

func _process(delta: float) -> void:
	# Debug
	$UI/DebugLabel.text = "debug stats:\nPS: " + str(bella_stats.hp) \
		+ "\nPP: " + str(bella_stats.pp) \
		+ "\n\n-enemigo-\nPS: " + str(enemy_stats.hp) \
		+ "\nPP: " + str(enemy_stats.pp)
		
	# TextboxBG & NextMarker position
	textbox_bg.texture.width = $UI/BG.size.x
	textbox_bg.texture.height = $UI/BG.size.y
	
	battle_marker_size = BattleMarker.texture.get_size()
	BattleMarker.position = $UI/BG.size - (battle_marker_size * 2) - Vector2(0, 20)
	BattleMarker.offset = battle_marker_size / 2
	
	# Rotate BG
	$BG.rotation_degrees.y += sphere_rotation * delta
	$BG.rotation_degrees.z += sphere_rotation * delta
	 
	# If Bella HP is low, change BG to reflect that
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
		
	# Idk about this one
	if enemy_stats.hp <= 0:
		enemy_stats.hp = 0
		
	update_stat_viewer()
	battle_loop()

func update_stat_viewer():
	PlayerHPBar.max_value = bella_stats.hp_max
	
	PlayerHPBar.value = lerp(int(PlayerHPBar.value), bella_stats.hp, 0.1)
	PlayerHPValue.text = str(bella_stats.hp) + "[font_size=8]/" + str(bella_stats.hp_max)
	
	PlayerPPBar.max_value = bella_stats.pp_max
	PlayerPPBar.value = bella_stats.pp
	PlayerPPValue.text = str(bella_stats.pp) + "[font_size=8]/" + str(bella_stats.pp_max)
	
	EnemyHPBar.value = lerp(int(EnemyHPBar.value), enemy_stats.hp, 0.1)
	EnemyHPBar.max_value = enemy_stats.hp_max
	EnemyHPValue.text = str(enemy_stats.hp) + "[font_size=8]/" + str(enemy_stats.hp_max)
	
	if not loosen_stat_viewer_position:
		PlayerStatContainer.position.x = stat_viewer_offset.x
		PlayerStatContainer.size.y = _sgt.window_size.y - stat_viewer_offset.y
		
		EnemyStatContainer.position.x = _sgt.window_size.x - EnemyStatContainer.size.y - enemy_stat_viewer_offset.x
		EnemyStatContainer.size.y = _sgt.window_size.y

func battle_loop():
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
					$UI/ActionBox/Button0.grab_focus()
						
			if enemy_stats.hp <= 0:
				#print("The check worked!")
				is_your_turn = false
				
				if not player_defeated_lock:
					anim_stat_viewer_hide(0)
					create_tween().tween_property($UI/EnemyStatContainer/EnemyStatViewer, "modulate:a", 0, 0.25)
					won_the_battle()
			
			if bella_stats.hp <= 0:
				#print("Bella check")
				is_your_turn = false

				if not player_defeated_lock:
					create_tween().tween_property($UI/EnemyStatContainer/EnemyStatViewer, "modulate:a", 0, 0.25)
					lost_the_battle()
					
			if win_switch:
				after_winning()
				
			if lose_switch:
				after_losing()

func after_winning():
	_fade.color = Color.BLACK
	_fade.fade_time = 0.5
	_fade._in.emit()
	
	_bgm.fade_out_bg()
	
	$Timer.start(0.5)
	await $Timer.timeout
	
	_sgt.flag_scene_changed_after_battle = true
	_load.change_scene(_sgt.flag_prev_scene, "AfterBattle")
	
func after_losing():
	_fade.fade_time = 0.5
	_fade.color = Color.BLACK
	_fade._in.emit()
	
	create_tween() \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property($Camera, 'v_offset', 0.5, _fade.fade_time * 2)
	_bgm.fade_out(_fade.fade_time)
	
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
		$UI/ActionBox/Button0.release_focus()

func _finish_chain():
	turn_chain_ready = false
	turn_order_read = 0
	turn_order.clear()
	delete_buttons()
	
	if ActionBox.has_node("Button0"):
		$UI/ActionBox/Button0.release_focus()

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
	$UI/PlayerStatContainer/StatViewer/AnimationPlayer.play("shake")
	
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
	
	
	_bgm.play_bg("bgm_fightover.ogg", 1, -50)
	_bgm.fade_in_bg()
	
	anim_enemy_defeated()
	
	create_tween().tween_property(ActionBox, "modulate:a", 0, 0.5)
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
		_bgm, "pitch_music", 0.50, 1)
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
	_bgm.fade_out()
	create_tween().tween_property($Camera, "offset_y", 1, 1)
	
	$BattleTimer.start(1.1)

func anim_arrow():
	BattleMarker.position.x -= anim_arrow_move
	
	anim_arrow_tween = create_tween()
	anim_arrow_tween.set_ease(Tween.EASE_OUT)
	anim_arrow_tween.set_trans(Tween.TRANS_CUBIC)
	anim_arrow_tween.tween_property(
		BattleMarker, "position:x", BattleMarker.position.x + anim_arrow_move, 0.5)

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
				ActionBox, "modulate:a", alpha, 0.1)

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
		
func anim_stat_viewer_show(value: float = 1.0, which_one: Node = $UI/PlayerStatContainer):
	loosen_stat_viewer_position = false
	create_tween().tween_property(which_one, "modulate:a", value, stat_viewer_move_speed)
	var tween = create_tween() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property(which_one, "position:x", stat_viewer_position.x, stat_viewer_move_speed)
	await tween.finished	
	loosen_stat_viewer_position = true
	$UI/PlayerStatContainer/StatViewer/AnimationPlayer.stop()

# ...yes, has almost the same code as the one at the top ._.
func anim_stat_viewer_hide(value: float = 0.5, which_one: Node = $UI/PlayerStatContainer):
	loosen_stat_viewer_position = false
	create_tween().tween_property(which_one, "modulate:a", value, stat_viewer_move_speed)
	var tween = create_tween() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property(which_one, "position:x", stat_viewer_position.x - 50, stat_viewer_move_speed)
	await tween.finished
	loosen_stat_viewer_position = true
	$UI/PlayerStatContainer/StatViewer/AnimationPlayer.stop()
			
func add_button(text: String, number: int, function: Callable):
	var font_milonga = load("res://assets/fonts/Milonga-Regular.ttf")
	var icon: Array = [
		load("res://assets/images/icon_battle_attack.png"),
		load("res://assets/images/icon_battle_talk.png"),
		load("res://assets/images/icon_battle_magic.png"),
		load("res://assets/images/icon_battle_item.png"),
		load("res://assets/images/icon_battle_run.png"),
	]
	var style: Array = [
		load("res://assets/scenes/battles/button_attack.tres"),
		load("res://assets/scenes/battles/button_magic.tres"),
		load("res://assets/scenes/battles/button_talk.tres"),
		load("res://assets/scenes/battles/button_item.tres"),
		load("res://assets/scenes/battles/button_run.tres"),
	]
	
	var button = Button.new()
	button.text = text
	button.icon = icon[number]
	button.expand_icon = true
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.add_theme_font_override("font", font_milonga)
	button.add_theme_font_size_override("font_size", 20)
	
	button.add_theme_stylebox_override("normal", style[number])
	button.add_theme_stylebox_override("pressed", style[number])
	
	button.add_to_group("battle_buttons")
	button.pressed.connect(function)
	
	button.name = "Button" + str(number)
	
	ActionBox.add_child(button)
	
func delete_buttons():
	for i in text_action_buttons_1.size():
		if get_tree().get_nodes_in_group("battle_buttons") and not win_anim_lock:
			get_node("UI/ActionBox/Button" + str(i)).queue_free()

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
			
	_bgm.fade_out()
	
	$Timer.start($FleeSound.stream.get_length() / 2)
	await $Timer.timeout
	
	_sgt.flag_scene_changed_after_winning = true
	
	# travel back to previous scene
	get_node('/root/auto_fade')._in.emit()
	print_rich("[color=red]This emitted[/color]")
	_load.change_scene(_sgt.flag_prev_scene, "AfterBattle")
	
func _on_flee_sound_finished() -> void:
	print("a")
