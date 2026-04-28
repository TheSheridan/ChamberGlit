# CODE REFACTORED!!!

# GOAL
# Fix cursor position

extends Control


# Variables
@export_file("*.tscn") var scene_to_change: String = "res://assets/scenes/maps/map_cave1_r1/map_cave1_r1.tscn"

var margin_size = 40
var menu_actual_option = 0
var is_menu_selected: bool = false

var menu_description_text

var other_text_pos_temp
var is_anim_button_on: bool = true

var anim_flip_switch: bool = false

# Timer variables for Input.action_pressed()
var timer_count = 0
var timer_count_limit = 80
var timer_2_count = 0
var timer_2_count_limit = 5

var quit_time = 0.5

enum menu {NEW_GAME, LOAD_GAME, SETTINGS, EXTRAS, QUIT}

# Animations
var button_offset_x = 3
var button_time = 0.25

enum slide {IN, OUT}

var anim_cursor_fade_time = 0.125

@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')
@onready var _loading = get_node('/root/n_animLoading')

@onready var button_vbox = $Margin/Ratio/ButtonVBox

@onready var new_game_button = $Margin/Ratio/ButtonVBox/NewGameButton
@onready var load_game_button = $Margin/Ratio/ButtonVBox/LoadGameButton
@onready var settings_button = $Margin/Ratio/ButtonVBox/SettingsButton
@onready var extras_button = $Margin/Ratio/ButtonVBox/ExtrasButton
@onready var quit_button = $Margin/Ratio/ButtonVBox/QuitButton

@onready var new_game_button_timer = $Margin/Ratio/ButtonVBox/NewGameButton/Timer
@onready var load_game_button_timer = $Margin/Ratio/ButtonVBox/LoadGameButton/Timer
@onready var settings_button_timer = $Margin/Ratio/ButtonVBox/SettingsButton/Timer
@onready var extras_button_timer = $Margin/Ratio/ButtonVBox/ExtrasButton/Timer
@onready var quit_button_timer = $Margin/Ratio/ButtonVBox/QuitButton/Timer

@onready var description_text = $Margin/Ratio/PromptVBox/DescriptionText
@onready var description_text_shadow = $Margin/Ratio/PromptVBox/DescriptionText/ShadowText
@onready var description_text_timer = $Margin/Ratio/PromptVBox/DescriptionText/ShadowText/Timer
@onready var other_text = $Margin/Ratio/PromptVBox/OtherText

@onready var banner = $Margin/Ratio/Banner
@onready var banner_shake = $Margin/Ratio/BannerShake
@onready var cursor = $Margin/Ratio/Cursor


func _ready():
	RenderingServer.set_default_clear_color(Color(0.1416015625, 0.14938354492188, 0.15625))
	_fade._out.emit()
	_loading._out.emit()
	
	$Camera2D.position = _sgt.window_size / 2
	  
	# DEBUG
	TranslationServer.set_locale("es")

	menu_description_text = [
		tr("MainMenu_NewGame_Info"),
		tr("MainMenu_LoadGame_Info"),
		tr("MainMenu_Settings_Info"),
		tr("MainMenu_Extras_Info"),
		tr("MainMenu_Quit_Info")
	]

	new_game_button.text = tr("MainMenu_NewGame")
	load_game_button.text = tr("MainMenu_LoadGame")
	settings_button.text = tr("MainMenu_Settings")
	extras_button.text = tr("MainMenu_Extras")
	quit_button.text = tr("MainMenu_Quit")
  
  	# Connect buttons to functions
	new_game_button.mouse_entered.connect(Callable(self, "b_mouse_entered_newGame"))
	load_game_button.mouse_entered.connect(Callable(self, "b_mouse_entered_loadGame"))
	settings_button.mouse_entered.connect(Callable(self, "b_mouse_entered_settings"))
	extras_button.mouse_entered.connect(Callable(self, "b_mouse_entered_extras"))
	quit_button.mouse_entered.connect(Callable(self, "b_mouse_entered_quit"))

	button_vbox.mouse_entered.connect(Callable(self, "b_mouse_entered_quit"))
	
	var lambda = func() -> void:
		print("Hello world")
	new_game_button.pressed.connect(lambda)
  
	# Margin size
	$Margin.offset_left += margin_size
	$Margin.offset_top += margin_size
	$Margin.offset_right -= margin_size
	$Margin.offset_bottom -= margin_size
  
	$Margin/Ratio.size = _sgt.window_size

	# Button prompt text
	other_text.custom_minimum_size.x = _sgt.window_size.x - margin_size * 2
	other_text.text = "[left][img=32x32]" + _sgt.get_button_prompt("Z") + "[/img]" \
	+ tr("Prompt_Accept") + "				[img=32x32]" + _sgt.get_button_prompt("X") + "[/img]" \
	+ tr("Prompt_Cancel") + "   		[img=32x32]" + _sgt.get_button_prompt("Arrow_Up") + "[/img]" \
	+ "[img=32x32]" + _sgt.get_button_prompt("Arrow_Down") + "[/img]" \
	+ tr("Prompt_Select")

	button_vbox.position += Vector2(40, 40)

	description_text.text = menu_description_text[menu_actual_option]

	# Audio
	$Audio.volume_db = -40.0
	$Audio.play()
	_sgt.music_play($Audio, slide.OUT, 0.5)
  
	other_text_pos_temp = Vector2(0, 332)

	# Decoration
	$Particles.scale = Vector2(4, 4)
	$Particles.z_index = -5

	$Grad.z_index = -4
	$Grad/Up.texture.width = _sgt.window_size.x
	$Grad/Down.texture.width = _sgt.window_size.x

	# Banner
	banner.position = Vector2(_sgt.window_size.x - banner.texture.get_width() - 90, 5)
	banner_shake.position = banner.position + Vector2(
		banner_shake.texture.get_width(),
		banner_shake.texture.get_height(),
	) / 2

	banner_shake.hide() # for now

	description_text_shadow.size.x = _sgt.window_size.x - description_text_shadow.position.x * 2


func _process(_delta):
  	# Detect mouse movement (WIP)
	# if Input.get_last_mouse_velocity() != Vector2(0, 0):
	# 	anim_cursorHide()
	# elif Input.is_action_just_pressed('ui_up') \
	# or Input.is_action_just_pressed('ui_down'):
	# 	anim_cursorShow()
  
	create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property(cursor, 'position:y', menu_actual_option * 36, 0.25)
	
	# Button prompt animation
	if new_game_button.pressed:
		Callable(self, "button_mouseHover_newGame")

	# Shake
	var rng = RandomNumberGenerator.new()
	var rng_range = 2
	var shake_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	var rng_position = Vector2(rng.randi_range(-rng_range, rng_range), rng.randi_range(-rng_range, rng_range))

	banner_shake.position += rng_position / 2

	shake_tween.tween_property(banner_shake, "position", banner.position \
		+ Vector2(
			rng.randi_range(-rng_range, rng_range),
			rng.randi_range(-rng_range, rng_range)) \
		+ Vector2(
			banner_shake.texture.get_width(), banner_shake.texture.get_height(), ) / 2,
		0.3
	)

	banner_shake.rotation_degrees = lerp(
		banner_shake.rotation_degrees,
		sin(rng.randi_range(-3, 3) * 2) * 2,
		0.4
	)
  
	# INPUT
	# Handling the pointing option
	if Input.is_action_just_pressed('ui_up'):
		# Try to not run this code if Up/Down is pressed enough
		if timer_count < timer_count_limit:
			timer_count = 0

		# sus
		menu_actual_option -= 1
		if menu_actual_option <= menu.NEW_GAME - 1:
			menu_actual_option = menu.QUIT
	
	if Input.is_action_just_pressed('ui_down'):
		# Try to not run this code if Up/Down is pressed enough
		if timer_count < timer_count_limit:
			timer_count = 0

		# sus
		menu_actual_option += 1
		if menu_actual_option >= menu.size():
			menu_actual_option = menu.NEW_GAME
  

	if Input.is_action_pressed('ui_up'):
		timer_count += 1
	
	#print("timer_count == " + str(timer_count))
	
		if timer_count >= timer_count_limit:
			timer_2_count += 1

			create_tween().set_ease(Tween.EASE_IN_OUT) \
					.set_trans(Tween.TRANS_QUAD) \
					.tween_property(
						description_text, "position",
						description_text.position + Vector2(button_offset_x, button_offset_x),
						button_time / 2)

			create_tween().set_ease(Tween.EASE_OUT) \
				.tween_property(description_text, "modulate", Color(description_text.modulate, 0), button_time / 3)
	
		if timer_2_count >= timer_2_count_limit:
			menu_actual_option -= 1 # <- This

			if menu_actual_option < menu.NEW_GAME:
				menu_actual_option = menu.QUIT

			timer_2_count = 0

	if Input.is_action_pressed('ui_down'):
		timer_count += 1
		
		if timer_count >= timer_count_limit:
		  # Animations
			create_tween().set_ease(Tween.EASE_IN_OUT) \
					.set_trans(Tween.TRANS_QUAD) \
					.tween_property(description_text, "position", description_text.position + Vector2(
						button_offset_x, button_offset_x),
					button_time / 2)

			create_tween().set_ease(Tween.EASE_OUT) \
					.tween_property(description_text, "modulate",
						Color(description_text.modulate, 0),button_time / 3)

			# Rest
			timer_2_count += 1
			if timer_2_count >= timer_2_count_limit:
				menu_actual_option += 1 # <- This

				if menu_actual_option > menu.QUIT:
					menu_actual_option = menu.NEW_GAME
				
				timer_2_count = 0
	
	if Input.is_action_just_released('ui_up') \
	or Input.is_action_just_released('ui_down'):
		timer_count = 0
		timer_2_count = 0
		anim_buttonFlip()

	# Animation when pointing to another option
	if Input.is_action_just_pressed('ui_up') \
	or Input.is_action_just_pressed('ui_down'):
		anim_buttonFlip()
	
	if Input.is_action_just_pressed('ui_accept') and !is_menu_selected:
		if menu_actual_option >= menu.NEW_GAME && menu_actual_option < menu.QUIT:
			_sgt.sfx_play("select")
		
		match menu_actual_option:
			menu.NEW_GAME:
				anim_buttonSlide(new_game_button, new_game_button_timer)
				_fade._in.emit()
				is_menu_selected = true
				
				$SceneChangeTimer.start(0.25)
				await $SceneChangeTimer.timeout
				
				_fade._in.emit()
				$SceneChangeTimer.start(_fade.fade_time)
				await $SceneChangeTimer.timeout
				
				_load.change_scene(scene_to_change)
				_sgt.music_play($Audio, _sgt._ease.IN, 0.25)

			menu.LOAD_GAME:
				anim_buttonSlide(load_game_button, load_game_button_timer)

			menu.SETTINGS:
				anim_buttonSlide(settings_button, settings_button_timer)

			menu.EXTRAS:
				anim_buttonSlide(extras_button, extras_button_timer)

			menu.QUIT:
				create_tween() \
						.set_ease(Tween.EASE_OUT) \
						.set_trans(Tween.TRANS_CUBIC) \
						.tween_property($Camera2D, 'zoom', Vector2(2, 2), 1)
				
				_sgt.music_play($Audio, _sgt._ease.IN, 0.25)
				_sgt.sfx_play("roll") # Too large for close the game's window on time?
				anim_buttonSlide(quit_button, quit_button_timer)
				_fade._in.emit()

				$TimerInput.start(quit_time) # <- Replace with a variable
				await $TimerInput.timeout
				get_tree().quit()
  
	$Particles.position = lerp(
		$Particles.position,
		Vector2(-80, -80) + (get_local_mouse_position() / Vector2(8, 4)),
		0.8
	)

 	# Thingy :)
	var thingy_shake = 1
	rng.randi_range(-thingy_shake, thingy_shake)

	# DisplayServer.window_set_position(
	# 	_sgt.window_position2 + Vector2(
	# 	rng.randi_range(-thingy_shake, thingy_shake),
	# 	rng.randi_range(-thingy_shake, thingy_shake))
	# )


# Buttons
func b_pressed_newGame():
	print("New game hovered!")
	
func b_pressed_loadGame():
	print("New game hovered!")
	
func b_pressed_settings():
	print("New game hovered!")
	
func b_pressed_extras():
	print("New game hovered!")
	
func b_pressed_quit():
	print("New game hovered!")
	

func anim_buttonSlide(button, button_timer):
	anim_buttonSlideIn(button)
	button_timer.start(0.1)
	await button_timer.timeout
	anim_buttonSlideOut(button)

func anim_buttonSlideIn(button):
	create_tween().set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property(
				button, "position:x",
				button.position.x + button_offset_x,
				button_time
			)
			
func anim_buttonSlideOut(button):
	create_tween().set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_QUAD) \
			.tween_property(button, "position:x", 0, button_time)

func anim_promptFlip(_ease):
	if _ease == slide.IN:
		create_tween().set_ease(Tween.EASE_IN) \
				.set_trans(Tween.TRANS_CUBIC) \
				.tween_property(description_text, "modulate",
					Color(description_text.modulate, 0), button_time / 3)
	elif _ease == slide.OUT:
		create_tween().set_ease(Tween.EASE_IN) \
				.set_trans(Tween.TRANS_CUBIC) \
				.tween_property(description_text, "modulate",
					Color(description_text.modulate, 1), button_time / 3)
	
func anim_buttonPromptMove():
	var timer = description_text_timer
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_CUBIC)
  
	var offset = 3
	var time = 0.5

	var rng = RandomNumberGenerator.new()
	var result = rng.randi_range(0, 3)
	
	match result:
		0:
			tween.tween_property(description_text_shadow, "position", other_text_pos_temp + Vector2(offset, 0), time)
		1:
			tween.tween_property(description_text_shadow, "position", other_text_pos_temp + Vector2(-offset, 0), time)
		2:
			tween.tween_property(description_text_shadow, "position", other_text_pos_temp + Vector2(0, offset), time)
		3:
			tween.tween_property(description_text_shadow, "position", other_text_pos_temp + Vector2(0, -offset), time)
			timer.start(time)
			await timer.timeout

func anim_cursorHide():
	create_tween().set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_SINE) \
			.tween_property(cursor, 'modulate', Color(cursor.modulate, 0), anim_cursor_fade_time)

func anim_cursorShow():
	create_tween().set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_SINE) \
			.tween_property(cursor, 'modulate', Color(cursor.modulate, 1), anim_cursor_fade_time)
	
func anim_buttonFlip():
	anim_promptFlip(slide.IN)
	_sgt.sfx_play('type')
	is_anim_button_on = false
	
	create_tween().set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_QUAD) \
			.tween_property(description_text, "position",
			
	description_text.position + Vector2(button_offset_x, button_offset_x), button_time / 2)
	description_text_timer.start(button_time / 5)
  
	await description_text_timer.timeout
	
	anim_flip_switch = true
	description_text.text = menu_description_text[menu_actual_option]
	anim_promptFlip(slide.OUT)
  
	create_tween().set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_QUAD) \
			.tween_property(description_text, "position", other_text_pos_temp, button_time / 2)
  
	is_anim_button_on = true
