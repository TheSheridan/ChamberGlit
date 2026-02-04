extends Node2D

# I REFACTORED THE CODE!!!!
# TODO: When it's cristmas put a snowflake sprite instead to the lighting one in $Particles


# @export var txt_glit_limits = 4
var previous_bgm_volume
var previous_txt_glit_position
var previous_glit_position: Vector2 # TODO: Find out what tf does this variable... karma hits hard.

# _process
var timer = 0
var timer_stop: bool = false
var lerp_time 	= 0.5
var bg_color = Color(0, 0, 0, 1)

# _physics_process
@export var press_start_scene: StringName
var press_start_switch: bool = false
var press_start_timer: int

# anim_expand_sprite()
var spr_expand_timer = 0
var spr_expand_timer_limit = 120
var spr_expand_tween: Tween

var spr_expand_rotation_freq: float = 15
var spr_expand_rotation_amp: float = 45
var spr_expand_rotation_time = 0

var spr_shake_alpha_time: int


# Autoloads
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')


# Main
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	_fade._out.emit()
	$AudioStreamPlayer.playing = true
	previous_bgm_volume = AudioServer.get_bus_volume_db(1)
	AudioServer.set_bus_volume_db(1, -6)

  # Particle positions
	$Particles/Snow1.position = -Vector2(10, 10)
	$Particles/Snow3.position = Vector2(-35, _sgt.window_size.x / 2)
	$Particles/Snow3.modulate = Color($Particles/Snow3.modulate, 0.05)

  # Text properties
	$Text.size.x              = _sgt.window_size.x
	$Text.pivot_offset        = Vector2($Text.size.x/2, $Text.size.y/2)
	$Text.text                = tr("Title2_GameByDev")
	$Text.visible_characters  = 0
	$Text.modulate            = Color($Text.modulate,0)

	$Text/TextGlit.size 		= $Text.size
	previous_txt_glit_position  = $Text/TextGlit.position
	previous_glit_position 	    = $PressStart/TextShake.position

	$Text/GlowLine.size = Vector2(
		_sgt.window_size.x,
		_sgt.window_size.y/12
	)
	
	$Text/GlowLine.modulate = Color($Text/GlowLine.modulate, 0)

	$Text/GlowLine/Up.scale.x   = _sgt.window_size.x
	$Text/GlowLine/Down.scale.x = _sgt.window_size.x

	# Logo properties
	$Logo.modulate   = Color($Logo.modulate,0)
	$Logo.size.x     = _sgt.window_size.x
	$Logo.position.x = _sgt.window_size.x / 2
	$Logo.position.y = _sgt.window_size.y / 2 - _sgt.window_size.y / 30

	$Logo/SpriteExpand.rotation_degrees = -2.5
	$Logo/SpriteExpand.modulate = Color($Logo/SpriteExpand.modulate, 0.2)

# Press Start properties
	$PressStart.size.x 		      = $Logo.size.x
	$PressStart.modulate 		    = Color($PressStart.modulate, 0)
	$PressStart/Text.text 		  = tr('Title2_PressStart_Any')
	$PressStart/TextShake.text  = tr('Title2_PressStart_Any')
  
# Gradient stuff
	$Gradient1.position 				    = Vector2(0, 0)
	$Gradient1.region_rect.size.y 	= _sgt.window_size.y / 8
	$Gradient1.scale 				        = Vector2(_sgt.window_size.x, 1)

	$Gradient2.position 				   = Vector2(0, _sgt.window_size.y - $Gradient2.region_rect.size.y)
	$Gradient2.region_rect.size.y  = _sgt.window_size.y / 8
	$Gradient2.scale 				       = Vector2(_sgt.window_size.x,1)

	create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property($Text, 'position:y', _sgt.window_size.y / 2 - _sgt.window_size.y / 30, 0.9)

	spr_expand_tween = create_tween() \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
  
# Press Start
	$PressStart.position.y = _sgt.window_size.y - _sgt.window_size.y / 4

	create_tween() \
		.tween_property($PressStart, 'modulate', Color($PressStart.modulate, 1), 0.5)

# Made by
	$MadeBy.size 			= _sgt.window_size
	$MadeBy.pivot_offset.y 	= $MadeBy.size.y
	$MadeBy.position.y 		= (_sgt.window_size.y) - (_sgt.window_size.y / 15)

# Camera
	$Camera2D.offset = Vector2(_sgt.window_size) / 2


func _process(delta):
	RenderingServer.set_default_clear_color(bg_color)
  
	create_tween().tween_property(self, 'bg_color', Color(0.07405599206686, 0.09171549975872, 0.109375), 0.25)

	if Input.is_key_pressed(KEY_CTRL) \
	and Input.is_key_pressed(KEY_ALT) \
	and Input.is_key_pressed(KEY_R):
		get_tree().change_scene_to_file('res://internal/scenes/scn_Title0/scn_Title0.tscn')

	if timer_stop == false:
		timer += 1
	  
	$Debug.text = 'spr_expand_timer=' + str(spr_expand_timer) \
	+ '\nlogo_spr_expand.scale = ' + str($Logo/SpriteExpand.scale)


# Typewriter effect
	if $Text.visible_characters != $Text.get_total_character_count():
		$Text.visible_characters += 1
	
	if $Text/TextGlit.visible_characters != $Text.get_total_character_count():
		$Text/TextGlit.visible_characters += 1
	
	$Text/TextGlit.text = $Text.text

# $Text shake
	$Logo/SpriteShake2.position = Vector2(
		previous_txt_glit_position.x + RandomNumberGenerator.new().randf_range(-2.5,2.5),
		previous_txt_glit_position.y + RandomNumberGenerator.new().randf_range(-2.5,2.5)
	)
  
	$Logo/Sprite.offset = Vector2(
		RandomNumberGenerator.new().randf_range(-0.2,0.2),
		RandomNumberGenerator.new().randf_range(-0.3,0.3)
	)
  
	$PressStart/TextShake.position = Vector2(
		previous_glit_position.x+RandomNumberGenerator.new().randf_range(-2.5,2.5),
		previous_glit_position.y+RandomNumberGenerator.new().randf_range(-2.5,2.5)
	)
  
	if timer == 2:
		create_tween().set_trans(Tween.TRANS_CUBIC) \
				.set_ease(Tween.EASE_OUT) \
				.tween_property($Logo, 'position:y', (_sgt.window_size.y / 2), 0.5)
	
	create_tween().tween_property($Logo, 'modulate', Color($Logo.modulate, 1), 0.25)

	timer_stop = true
  
	anim_expand_sprite()
	anim_shake_sprite(delta)

# Press Start
	if Input.is_anything_pressed() and press_start_switch == false:
		create_tween().set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_CUBIC) \
			.tween_property($Camera2D, 'zoom', Vector2(8,8), 0.5)

		create_tween().set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_CUBIC) \
		.tween_property(self, 'modulate', Color(modulate, 0), 0.25)

		create_tween().tween_property($AudioStreamPlayer, 'volume_db', -50, 1)

		press_start_switch = true
	
	if press_start_switch == true:
		press_start_timer += 1
		
	if press_start_timer == 20:
		$Camera2D.zoom = Vector2(1,1)
		_load.changeScene("res://assets/scenes/scn_mainMenu/scn_mainMenu.tscn")


func _physics_process(delta):
	anim_rotate_sprite(delta)

	$Text/TextGlit.position = \
	#lerp(
	#	previous_txt_glit_position,
	#	previous_txt_glit_position + Vector2(
	#		RandomNumberGenerator.new().randf_range(-2,2),
	#		RandomNumberGenerator.new().randf_range(-2,2)
	#	), lerp_time
	#)
	previous_txt_glit_position + Vector2(
			RandomNumberGenerator.new().randf_range(-2,2),
			RandomNumberGenerator.new().randf_range(-2,2)
	)

	$Logo/SpriteShake.position = $Text/TextGlit.position

func anim_expand_sprite():
	# Zoom
	spr_expand_timer += 1
	
	if spr_expand_timer >= spr_expand_timer_limit:
		spr_expand_timer = 0
  
	if spr_expand_timer == 1:
		create_tween().set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)\
			.tween_property($Logo/SpriteExpand, 'scale', Vector2(2.05, 2.05), 1)
	
	# sus			
	if spr_expand_timer == float(spr_expand_timer_limit / 2.0):
		create_tween().set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT) \
			.tween_property($Logo/SpriteExpand, 'scale', Vector2(1.8, 1.8), 1)

func anim_rotate_sprite(delta):
	spr_expand_rotation_time += delta
	var move = sin(spr_expand_rotation_time * spr_expand_rotation_freq) * spr_expand_rotation_amp
	$Logo/SpriteExpand.rotation_degrees += move * delta
	
func anim_shake_sprite(delta):
	spr_shake_alpha_time += delta
	var move = sin(spr_shake_alpha_time * 15) * 45

	$Logo/SpriteShake.modulate.a  += move * delta
	$Logo/SpriteShake2.modulate.a += move * delta
