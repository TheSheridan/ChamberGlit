# CHANGELOG:
# Main Menu done.
# Button signal functions deleted. (Jan 3, 2025)
#
# PLAN:
# Focus on interactions with the cursor.
# - [DONE] Detect when moving the mouse for hide $cursor, if a key is pressed then show it
# - Select buttons while mouse hovering them

## The main menu scene.

extends Control

# Variables
var timer_input_delay = 2
var margin_size = 40
var menu_optionActual = 0
var menu_isSelected: bool = false

var menu_descriptionText

var label_pos_temp
var anim_buttonPromptMove_isOn: bool = true

var timer2
var anim_promptFlip_switch: bool = false

# Timer variables for Input.action_pressed()
var timer_int = 0
var timer_int_limit = 40
var timer2_int = 0
var timer2_int_limit = 5

var quit_time = 0.5

@onready var window_pos = DisplayServer.window_get_size()

enum menu {NEW_GAME, LOAD_GAME, SETTINGS, EXTRAS, QUIT}

# Resources
@onready var _sgt = get_node('/root/auto_singleton')
@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')

# TODO: Get rid of this crap
@onready var cont_margin = $cont_margin
@onready var cont_ratio = $cont_margin/cont_ratio
@onready var vbox_buttons = $cont_margin/cont_ratio/vbox_buttons
@onready var vbox_prompt = $cont_margin/cont_ratio/vbox_prompt
@onready var b_newGame = $cont_margin/cont_ratio/vbox_buttons/b_newGame
@onready var b_loadGame = $cont_margin/cont_ratio/vbox_buttons/b_loadGame
@onready var b_settings = $cont_margin/cont_ratio/vbox_buttons/b_settings
@onready var b_extras = $cont_margin/cont_ratio/vbox_buttons/b_extras
@onready var b_quit = $cont_margin/cont_ratio/vbox_buttons/b_quit
@onready var b_newGame_timer = $cont_margin/cont_ratio/vbox_buttons/b_newGame/timer
@onready var b_loadGame_timer = $cont_margin/cont_ratio/vbox_buttons/b_loadGame/timer
@onready var b_settings_timer = $cont_margin/cont_ratio/vbox_buttons/b_settings/timer
@onready var b_extras_timer = $cont_margin/cont_ratio/vbox_buttons/b_extras/timer
@onready var b_quit_timer = $cont_margin/cont_ratio/vbox_buttons/b_quit/timer
@onready var label = $cont_margin/cont_ratio/vbox_prompt/label
@onready var label_promptshadow = $cont_margin/cont_ratio/vbox_prompt/label/colorRect
@onready var label_desc = $cont_margin/cont_ratio/vbox_prompt/label_desc
@onready var label_desc_timer = $cont_margin/cont_ratio/vbox_prompt/label_desc/timer
@onready var label_shadow = $cont_margin/cont_ratio/vbox_prompt/label_desc/label_shadow
@onready var label_shadow_timer = $cont_margin/cont_ratio/vbox_prompt/label_desc/label_shadow/timer
@onready var cursor = $cont_margin/cont_ratio/cursor
@onready var cursor_glow = $cont_margin/cont_ratio/cursor/glow
@onready var bgm = $bgm
@onready var timer_input2 = $timer_input2
@onready var timer_input = $timer_input
@onready var ptc = $ptc
@onready var grad = $grad
@onready var grad_up = $grad/up
@onready var grad_down = $grad/down
@onready var banner = $cont_margin/cont_ratio/banner
@onready var banner_glit = $cont_margin/cont_ratio/banner_glit

# Main
func _ready():
  # Fade
  _fade._out.emit()
  
  # Translation stuff
  TranslationServer.set_locale("es") # DEBUG

  menu_descriptionText = [
    tr("MainMenu_NewGame_Info"),
    tr("MainMenu_LoadGame_Info"),
    tr("MainMenu_Settings_Info"),
    tr("MainMenu_Extras_Info"),
    tr("MainMenu_Quit_Info")
  ]

  b_newGame.text  = tr("MainMenu_NewGame")
  b_loadGame.text = tr("MainMenu_LoadGame")
  b_settings.text = tr("MainMenu_Settings")
  b_extras.text   = tr("MainMenu_Extras")
  b_quit.text     = tr("MainMenu_Quit")
  
  
  # Buttons
  # b_newGame.mouse_filter = true
  # b_loadGame.mouse_filter = true
  # b_settings.mouse_filter = true
  # b_extras.mouse_filter = true
  # b_quit.mouse_filter = true
  
  b_newGame.mouse_entered.connect( Callable(self, "b_mouse_entered_newGame") )
  b_loadGame.mouse_entered.connect( Callable(self, "b_mouse_entered_loadGame") )
  b_settings.mouse_entered.connect( Callable(self, "b_mouse_entered_settings") )
  b_extras.mouse_entered.connect( Callable(self, "b_mouse_entered_extras") )
  b_quit.mouse_entered.connect( Callable(self, "b_mouse_entered_quit") )
  
  vbox_buttons.mouse_entered.connect( Callable(self, "b_mouse_entered_quit") )
  
  
  # Margin size
  cont_margin.offset_left   += margin_size
  cont_margin.offset_top    += margin_size
  cont_margin.offset_right  -= margin_size
  cont_margin.offset_bottom -= margin_size
  
  # Others
  cont_ratio.size = _sgt.window_size
  
  label.custom_minimum_size.x = _sgt.window_size.x - margin_size * 2
  label.text = "[left][img=32x32]" + _sgt.getButtonPrompt("Z") + "[/img]" \
  + tr("Prompt_Accept") + "				[img=32x32]" + _sgt.getButtonPrompt("X") + "[/img]" \
  + tr("Prompt_Cancel") + "   		[img=32x32]" + _sgt.getButtonPrompt("Arrow_Up") + "[/img]" \
  + "[img=32x32]" + _sgt.getButtonPrompt("Arrow_Down") + "[/img]" \
  + tr("Prompt_Select")
  
  vbox_buttons.position += Vector2(40, 40)
  
  label_desc.text = menu_descriptionText[menu_optionActual]
  
  bgm.volume_db = -40.0
  bgm.play()
  _sgt.music_play(bgm, slide.OUT, 0.5)
  
  #print(label_desc.position)
  label_pos_temp = Vector2(0, 332)

  # color added through godot code editor
  RenderingServer.set_default_clear_color(Color(0.1416015625, 0.14938354492188, 0.15625))

  # Decoration
  ptc.scale = Vector2(4, 4)
  ptc.z_index = -5

  grad.z_index = -4
  grad_up.texture.width   = _sgt.window_size.x
  grad_down.texture.width = _sgt.window_size.x

  # Banner
  banner.position = Vector2(_sgt.window_size.x - banner.texture.get_width() - 90, 5)
  banner_glit.position = banner.position + Vector2(
    banner_glit.texture.get_width(),
    banner_glit.texture.get_height(),
  ) / 2

  banner_glit.hide() # for now

  label_promptshadow.size.x = _sgt.window_size.x - label_promptshadow.position.x * 2

func _process(_delta):
  # Detect mouse movement
  if Input.get_last_mouse_velocity() != Vector2(0, 0):
    anim_cursorHide()
  elif Input.is_action_just_pressed('ui_up') \
  or	 Input.is_action_just_pressed('ui_down'):
    anim_cursorShow()
  
  # Select buttons
  

  # Input
  #print('menu_optionActual == ' + str(menu_optionActual))
  
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_CUBIC) \
  .tween_property(cursor, 'position:y',
    menu_optionActual * 36, # Theme margins
    0.25)
  
  # Button prompt animation
  #if anim_buttonPromptMove_isOn:
  #	anim_buttonPromptMove()
  if b_newGame.pressed:
    Callable(self, "button_mouseHover_newGame")


  # Glit
  var rang3 = 2
  var rng = RandomNumberGenerator.new()
  var tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
  var pos_rand = Vector2(rng.randi_range(-rang3, rang3), rng.randi_range(-rang3, rang3))

  banner_glit.position += pos_rand / 2

  tw.tween_property(banner_glit, "position",
    banner.position + Vector2(
      rng.randi_range(-rang3, rang3),
      rng.randi_range(-rang3, rang3)
    ) + Vector2(
      banner_glit.texture.get_width(),
      banner_glit.texture.get_height(),
    ) / 2,
    0.3
  )

  banner_glit.rotation_degrees = lerp(
    banner_glit.rotation_degrees,
    sin(rng.randi_range(-3, 3) * 2) * 2,
    0.4
  )
  
  # INPUT
  # Handling the pointing option
  if Input.is_action_just_pressed('ui_up'):
    # Try to not run this code if UP/DOWN is pressed enough
    if timer_int < timer_int_limit:
      timer_int = 0

    menu_optionActual -= 1
    if menu_optionActual <= menu.NEW_GAME - 1:
      menu_optionActual = menu.QUIT
    
  if Input.is_action_just_pressed('ui_down'):
    # Try to not run this code if UP/DOWN is pressed enough
    if timer_int < timer_int_limit:
      timer_int = 0

    menu_optionActual += 1
    if menu_optionActual >= menu.size():
      menu_optionActual = menu.NEW_GAME
  

  if Input.is_action_pressed('ui_up'):
    timer_int += 1
    
    #print("timer_int == " + str(timer_int))
    
    if timer_int >= timer_int_limit:
      timer2_int += 1

      create_tween().set_ease(Tween.EASE_IN_OUT) \
      .set_trans(Tween.TRANS_QUAD) \
      .tween_property(label_desc, "position",
        label_desc.position + Vector2(button_offset_x, button_offset_x),
        button_time / 2)

      create_tween().set_ease(Tween.EASE_OUT) \
      .tween_property(label_desc, "modulate",
        Color(label_desc.modulate, 0), button_time / 3)
  
      if timer2_int >= timer2_int_limit:
        menu_optionActual -= 1 # <- This

        if menu_optionActual < menu.NEW_GAME:
          menu_optionActual = menu.QUIT

        timer2_int = 0

  if Input.is_action_pressed('ui_down'):
    timer_int += 1
    if timer_int >= timer_int_limit:
      # Animations
      create_tween().set_ease(Tween.EASE_IN_OUT) \
      .set_trans(Tween.TRANS_QUAD) \
      .tween_property(label_desc, "position",
        label_desc.position + Vector2(button_offset_x, button_offset_x),
        button_time / 2)

      create_tween().set_ease(Tween.EASE_OUT) \
      .tween_property(label_desc, "modulate",
        Color(label_desc.modulate, 0), button_time / 3)

      # Rest
      timer2_int += 1
      if timer2_int >= timer2_int_limit:
        menu_optionActual += 1 # <- This

        if menu_optionActual > menu.QUIT:
          menu_optionActual = menu.NEW_GAME
        
        timer2_int = 0
    
  if Input.is_action_just_released('ui_up') \
  or Input.is_action_just_released('ui_down'):
    timer_int = 0
    timer2_int = 0
    anim_buttonFlip()

  # Animation when pointing to another option
  if Input.is_action_just_pressed('ui_up') \
  or Input.is_action_just_pressed('ui_down'):
    anim_buttonFlip()
  
  if Input.is_action_just_pressed('cg_accept') and !menu_isSelected:
    #print("Accept pressed.")
    
    # Play a SFX while pressed (except Quit because it plays another sound)
    # also is pretty inconvenient to add this code in the 'match' so I'm doing it with a 'if'
    if menu_optionActual >= menu.NEW_GAME && menu_optionActual < menu.QUIT:
      _sgt.sfx_play("select")
    
    match menu_optionActual:
      menu.NEW_GAME:
        anim_buttonSlide(b_newGame, b_newGame_timer)
        _fade._in.emit()
        menu_isSelected = true

        #print("For now NEW GAME doesn't do much other than fade the screen to black.\n"
        #+ "I'm gonna add more to this in the future.")

        _load.changeScene("res://assets/scenes/maps/map_cave1_r1/map_cave1_r1.tscn")
          
        _sgt.music_play(bgm, _sgt._ease.IN, 0.25)

      menu.LOAD_GAME:
        anim_buttonSlide(b_loadGame, b_loadGame_timer)

      menu.SETTINGS:
        anim_buttonSlide(b_settings, b_settings_timer)

      menu.EXTRAS:
        anim_buttonSlide(b_extras, b_extras_timer)

      menu.QUIT:
        _sgt.music_play(bgm, _sgt._ease.IN, 0.25)
        # Play a special SFX while pressed QUIT
        _sgt.sfx_play("roll") # Too large for close the game's window on time?

        anim_buttonSlide(b_quit, b_quit_timer)
        _fade._in.emit()
        timer_input.start(quit_time)	  # <- Replace with a variable
        await timer_input.timeout
        get_tree().quit()
  
  # Thingy :)
  var thingy_shake = 1
  # var window_pos2 = Vector2(
  #   window_pos.x - _sgt.window_size.x,
  #   window_pos.y - _sgt.window_size.y
  # )

  ptc.position = lerp(
    ptc.position,
    Vector2(-80, -80) \
    + (get_local_mouse_position() / Vector2(8, 4)),
    0.8
  )
  print(ptc.position)

  #print("window_pos2 is " + str(window_pos))

  rng.randi_range(-thingy_shake, thingy_shake)
  # DisplayServer.window_set_position(
  # 	window_pos2 + Vector2(
  # 	rng.randi_range(-thingy_shake, thingy_shake),
  # 	rng.randi_range(-thingy_shake, thingy_shake))
  # )


# Buttons
func b_pressed_newGame(): print("New game hovered!")
func b_pressed_loadGame(): print("New game hovered!")
func b_pressed_settings(): print("New game hovered!")
func b_pressed_extras(): print("New game hovered!")
func b_pressed_quit(): print("New game hovered!")


# Animations
var button_offset_x = 3
var button_time = 0.25

enum slide {IN, OUT}
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
  .tween_property(
    button, "position:x",
    0,
    button_time
  )

func anim_promptFlip(_ease):
  if _ease == slide.IN:
    create_tween().set_ease(Tween.EASE_IN) \
    .set_trans(Tween.TRANS_CUBIC) \
    .tween_property(label_desc, "modulate",
      Color(label_desc.modulate, 0), button_time / 3)
    
  elif _ease == slide.OUT:
    create_tween().set_ease(Tween.EASE_IN) \
    .set_trans(Tween.TRANS_CUBIC) \
    .tween_property(label_desc, "modulate",
      Color(label_desc.modulate, 1), button_time / 3)
    
func anim_buttonPromptMove():
  var timer = label_shadow_timer
  var tw = create_tween().set_ease(Tween.EASE_IN_OUT) \
    .set_trans(Tween.TRANS_CUBIC)
  
  var offset = 3
  var time = 0.5

  var rng = RandomNumberGenerator.new()
  var result = rng.randi_range(0, 3)
  match result:
    0:
      tw.tween_property(label_shadow, "position",
        label_pos_temp + Vector2(offset, 0), time)
    1:
      tw.tween_property(label_shadow, "position",
        label_pos_temp + Vector2(-offset, 0), time)
    2:
      tw.tween_property(label_shadow, "position",
        label_pos_temp + Vector2(0, offset), time)
    3:
      tw.tween_property(label_shadow, "position",
        label_pos_temp + Vector2(0, -offset), time)
  
  timer.start(time)
  await timer.timeout

var anim_cursorHide_fadeTime = 0.125
func anim_cursorHide():
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_SINE) \
  .tween_property(cursor, 'modulate', Color(cursor.modulate, 0),
    anim_cursorHide_fadeTime)

func anim_cursorShow():
  create_tween().set_ease(Tween.EASE_OUT) \
  .set_trans(Tween.TRANS_SINE) \
  .tween_property(cursor, 'modulate', Color(cursor.modulate, 1),
    anim_cursorHide_fadeTime)
    
func anim_buttonFlip():
  anim_promptFlip(slide.IN)
  _sgt.sfx_play('type')

  anim_buttonPromptMove_isOn = false

  create_tween().set_ease(Tween.EASE_IN_OUT) \
  .set_trans(Tween.TRANS_QUAD) \
  .tween_property(label_desc, "position",
    label_desc.position + Vector2(button_offset_x, button_offset_x),
    button_time / 2)
    
  label_desc_timer.start(button_time / 5)
  
  await label_desc_timer.timeout
  anim_promptFlip_switch = true
  label_desc.text = menu_descriptionText[menu_optionActual]
  anim_promptFlip(slide.OUT)
  
  create_tween().set_ease(Tween.EASE_IN_OUT) \
  .set_trans(Tween.TRANS_QUAD) \
  .tween_property(label_desc, "position",
    label_pos_temp,
    button_time / 2)
  
  anim_buttonPromptMove_isOn = true
