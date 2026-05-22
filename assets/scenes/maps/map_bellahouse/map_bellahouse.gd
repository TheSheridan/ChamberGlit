extends Node2D


@onready var _sgt = $/root/auto_singleton
@onready var _loading = $/root/n_animLoading

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

@export var start_in_bed: bool = false


# TODO: Find out why Bella's fade color changes to black.
# It's causing a flicker here.
func _ready() -> void:
	# Debug:
	_sgt.flag_minotaur_friends_scene = 1
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# "Start in bed" stuff
	if _sgt.flag_bella_house_appear_in_bed:
		start_in_bed = true
		
		if _sgt.flag_bella_house_after_cave1:
			bella.fade_color = Color.WHITE
			
			var timer = get_tree().create_timer(bella.fade_duration)
			await timer.timeout
			print("Fade timer finished -- Bella's fade color is BLACK now.")
			
			bella.fade_color = Color.BLACK
			_loading.sprite_color = true
	
		# Deactivate flags
		_sgt.flag_bella_house_appear_in_bed = false
		_sgt.flag_bella_house_after_cave1 = false
	
	if start_in_bed:
		bella.position = $PositionHelpers/Bed.position
		start_in_bed = false
	
	# Coloring Crap (TM)
	$Mom/Sprite2D.modulate = Color.AQUAMARINE
	
	# Post-boss 1 scene
	if not _sgt.flag_minotaur_friends_scene:
		$BGM.play()
	
	_loading._out.emit()
	bella._fade_out.emit()

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
