# TODO list:
# - [Cancel]->Show choices in a line with them
# - Extra animations


extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.


## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given cue when using balloon as a [Node] in a scene.
@export var start_from_cue: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## A sound player for voice lines (if they exist).
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## (CG) Sound player for the Select sound.
@onready var next_sound = $NextSound
## (CG) Sound player for the Select sound.
@onready var choice_sound = $ChoiceSound
## (CG) Sound player for the Accept sound.
@onready var accept_sound = $AcceptSound
## (CG) Sound player for individual letters.
@onready var talk_sound = $TalkSound

@onready var touchpad = $"/root/Touchpad"

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

var has_choices_closed: bool = false

## Tween for animations
var anim_textbox_tween: Tween
@onready var responses_anim = %ResponsesAnim
@onready var progress_anim = $Balloon/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Control/AnimationPlayer

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon			
			progress_anim.play("fade_out")
			$FadeAnim.play("fade_out")
			touchpad._in.emit()
			
			# TODO: Fix this, it causes to not respond when talking again
			if $FadeAnim.is_playing and $FadeAnim.current_animation == "fade_out":
				await $FadeAnim.animation_finished
			
			is_running_dialog = false
			after_closing = true
			
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Indicator to show that player can progress dialogue.
@onready var progress: Sprite2D = %Progress

# My stuff
signal dialog
signal far_of_npc

@export var is_running_dialog: bool = false
@export var after_closing: bool = false

@onready var text_speed_normal = dialogue_label.seconds_per_step
@onready var text_speed_double = dialogue_label.seconds_per_step / 5

func _ready() -> void:
	balloon.hide()
	balloon.modulate.a = 0
	responses_anim.play("normal")

	dialog.connect(_on_dialog.bind())
	
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()
		
	# Doesn't work.
	#far_of_npc.connect(close.bind())


func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		if not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not dialogue_line.has_tag("voice"):
			progress_anim.play("fade_in")
		
		play_talk_sound()
		
		if Input.is_action_pressed("ui_select"):
			dialogue_label.seconds_per_step = text_speed_double
		if Input.is_action_just_released("ui_select"):
			dialogue_label.seconds_per_step = text_speed_normal
	
	if is_running_dialog:
		if dialogue_resource == null:
			far_of_npc.emit()
		
		if far_of_npc:
			close()


func play_talk_sound():
	if not dialogue_line.text.is_empty():
		pass

func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		await dialogue_line.refresh()
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, cue: String = "", extra_game_states: Array = []) -> void:
	is_running_dialog = true
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	
	responses_menu.modulate.a = 0
	progress_anim.play("fade_out")
	touchpad._out.emit()

	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not cue.is_empty():
		start_from_cue = cue
		
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, temporary_game_states)
	
	show()


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	if has_choices_closed:
		progress_anim.play("fade_out")
	else:
		close()
		#responses_menu.hide()
	
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for next line
	if dialogue_line.has_tag("voice"):
		#print("1")
		audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"))
		audio_stream_player.play()
		await audio_stream_player.finished
		next(dialogue_line.next_id)
	# Choices appear
	elif dialogue_line.responses.size() > 0:
		#print("2")
		$ResponsesAnim.play("fade_in")
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
		
		#anim_responses(0)
		choice_sound.play()
		
		has_choices_closed = true
	elif dialogue_line.time != "":
		#print("3")
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	# Text after choice
	else:
		#print("4")
		
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:	
	if has_choices_closed:
		accept_sound.play()
		has_choices_closed = false
	else:
		next_sound.play()
	
	# DANGER: This is a bug mine, place a chech here!!!!
	# It returns null when Bella gets far of the NPC is talking to.
	if not dialogue_resource == null:
		dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)
	else:
		far_of_npc.emit()
		close()

func close():	
	if not dialogue_line.responses.size() > 0 and not has_choices_closed:
		responses_anim.play("fade_out")
	
	# The rest of the logic is handled in %ResponsesMenu
	
	#if responses_anim.is_playing():
		#await responses_anim.animation_finished
	#else:
		#queue_free()

#region animations

#func anim_responses(state: bool):
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_OUT)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#
	#var default_pos: float = 640
	#var show_pos: float = 290.5
	#var time: float = 0.5
	#
	#match state:
		#0:
			#tween.tween_property($%ResponsesMenu, 'position:x', show_pos, time)
		#1:
			#tween.tween_property($%ResponsesMenu, 'position:x', default_pos, time)
#
#func anim_textbox(state: bool):
	#anim_textbox_tween = create_tween()
	#anim_textbox_tween.set_ease(Tween.EASE_OUT)
	#anim_textbox_tween.set_trans(Tween.TRANS_CUBIC)
	#
	#var time: float = 0.5
#
	#anim_textbox_tween.tween_property(balloon, 'modulate:a', state, time)
	#await anim_textbox_tween.finished
	#anim_textbox_tween = null
	

#endregion

#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# Fast dialogue
	if Input.is_action_pressed("ui_cancel"):
		dialogue_label.seconds_per_step = text_speed_double
	else:
		dialogue_label.seconds_per_step = text_speed_normal
			
	
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			#dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)

#endregion

func _on_dialog() -> void:
	start(dialogue_resource)

func _on_dialogue_label_spoke(letter: String, letter_index: int, speed: float) -> void:
	talk_sound.play()

func _on_dialogue_label_finished_typing() -> void:
	progress_anim.play("fade_in")
	#pass
	#print("Finished typing!")
