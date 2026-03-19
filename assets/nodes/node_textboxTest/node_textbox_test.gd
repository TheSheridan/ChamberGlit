extends Control


var text: Array = [
	"[b][color=lightblue]Bella:[/color][/b] Hogar [wave]frío[/wave] hogar. Mami ya salió, así que puedo salir sin trabas.",
	"Asegúrate de equiparte algunas armas de la tienda de ? antes de salir de la aldea.",
	"Ya sabes lo peligrosos que pueden ser los animales salvajes.",
	"¡Eureka! Los códigos fueron almacenados en tu cabeza.",
]
var text_actual: int = 0

@export var letter_time: float = 0.1

# Instead of label.get_total_character_count()...
@onready var all_characters = text[text_actual].length()

@onready var label = $MarginContainer/AspectRatioContainer/RichTextLabel


func _ready() -> void:
	start()

func _process(delta: float) -> void:
	while label.visible_characters < all_characters:
		$Timer.start(letter_time)
		await $Timer.timeout
		label.visible_characters += 1
		
	if Input.is_action_just_pressed("ui_accept"):
		if label.visible_characters < all_characters:
			label.visible_characters = all_characters
			label.text = text[text_actual]
		else:
			if text_actual < text.size() - 1:
				next_line()
			else:
				anim_end()
				
func start():
	text_actual = 0
	label.visible_characters = 0
	label.text = text[text_actual]
	
	anim_start()

func next_line():
	text_actual += 1
	label.visible_characters = 0
	label.text = text[text_actual]

# They're empty for now()
func anim_start():
	show()

func anim_end():
	hide()
