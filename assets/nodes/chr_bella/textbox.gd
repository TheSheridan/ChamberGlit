extends Control


@export var text: Array = [
	"[b][color=lightblue]Bella:[/color][/b] Hogar [wave]frío[/wave] hogar. Mami ya salió, así que puedo salir sin trabas.",
	"Asegúrate de equiparte algunas armas de la tienda de ? antes de salir de la aldea.",
	"Ya sabes lo peligrosos que pueden ser los animales salvajes.",
	"¡Eureka! Los códigos fueron almacenados en tu cabeza.",
]
var text_actual: int = 0

@export var fade_duration: float = 0.05
@export var scale_duration: float = 0.2

var is_on: bool = false

signal already_closed
signal stand_still

var entered_area: bool
var exited_area: bool

@onready var arrow_position_x: float = $Arrow.position.x
@export var arrow_position_offset: float = 10.0

# Instead of label.get_total_character_count()...
var all_characters
@export var letter_time: float = 0.000625

@onready var label = $LabelMargin/Ratio/Label

# Tweens
@onready var tween: Tween = create_tween()
@onready var tween_arrow: Tween = create_tween()
@onready var tween_arrow_position: Tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
@onready var tween_scale: Tween = create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)


func _ready() -> void:
	modulate = Color(modulate, 0)
	$Arrow.modulate = Color($Arrow.modulate, 0)
	
	$Timer.connect("timeout", _on_Timer_timeout.bind())

func _process(delta: float) -> void:
	if is_on:
		if Input.is_action_pressed('ui_cancel'):
			advance_text_fast()
		else:
			advance_text()
		
		if Input.is_action_just_pressed("ui_accept"):
			input()
	#else:
	#	post_input()
		
func post_input():
	if not exited_area:
		if Input.is_action_just_pressed("ui_accept"):
			reset()
	
func advance_text():
	all_characters = text[text_actual].length()
	
	if label.visible_characters < all_characters:
		if not $Timer.is_stopped():
			return
		
		$Timer.start(letter_time)
	else:
		anim_arrow(1)
		
func advance_text_fast():
	all_characters = text[text_actual].length()
	
	if label.visible_characters < all_characters:
		if not $Timer.is_stopped():
			return
		
		for i in range(3):
			if label.visible_characters < all_characters:
				label.visible_characters += 1
				$LetterSound.play()
	else:
		anim_arrow(1)
		
func _on_Timer_timeout():
	label.visible_characters += 1
	$LetterSound.play()
		
	if label.visible_characters >= text[text_actual].length():
		$Timer.stop()
		
func input():
	if label.visible_characters < all_characters:
		label.visible_characters = all_characters
		label.text = text[text_actual]
	else:
		if text_actual < text.size() - 1:
			next_line()
		else:
			anim_fade(0)
			is_on = false
			already_closed.emit()
	
			
func start():
	text_actual = 0
	label.visible_characters = 0
	label.text = text[text_actual]
	
	anim_fade(1)
	$Arrow.modulate = Color(modulate, 0)

func next_line():
	text_actual += 1
	label.visible_characters = 0
	label.text = text[text_actual]
	
	anim_arrow(0)

func reset():
	text_actual = 0
	label.visible_characters = 0
	label.text = text[text_actual]
	
	anim_fade(1)
	$Arrow.modulate = Color(modulate, 0)
	
	is_on = true
	stand_still.emit()

## Fades the textbox. 0 = Hide, 1 = Show.
func anim_fade(state: bool):
	tween = create_tween()
	tween.tween_property(self, 'modulate', Color(modulate, state), fade_duration)

## Fades the next dialogue indicator. 0 = Hide, 1 = Show.
func anim_arrow(state: float):
	tween_arrow = create_tween()
	
	tween_arrow_position = create_tween()
	tween_arrow_position.set_ease(Tween.EASE_OUT)
	tween_arrow_position.set_trans(Tween.TRANS_CUBIC)
	
	tween_arrow.tween_property($Arrow, 'modulate', Color(modulate, state), fade_duration)
	
	if state == 0:
		tween_arrow_position.tween_property(
			$Arrow, 'position:x', arrow_position_x, fade_duration)
	else:
		tween_arrow_position.tween_property(
			$Arrow, 'position:x', arrow_position_x + arrow_position_offset, fade_duration)

func _on_character_bella_open_textbox() -> void:
	anim_fade(1)
	start()
	is_on = true

func _on_character_bella_close_textbox() -> void:
	anim_fade(0)
	is_on = false

func _on_character_bella_entered_area_2() -> void:
	entered_area = true

func _on_character_bella_exited_area_2() -> void:
	exited_area = true
