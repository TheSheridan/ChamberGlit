extends Node2D


@onready var _sgt = $/root/auto_singleton
@onready var _load = $/root/auto_load
@onready var _loading = $"/root/n_animLoading"
@onready var _bgm = $"/root/bgm"

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

@export var start_in_bed: bool = false


# TODO: Find out why Bella's fade color changes to black.
# It's causing a flicker here.
func _ready() -> void:
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
	match _sgt.flag_minotaur_friends_scene:
		1:
			$BGM.stop()
			print("is true")
		_:
			$Mom.queue_free()
			print("failed")
	
	_loading._out.emit()
	bella._fade_out.emit()
	
	_bgm.play_music("bgm_myplace.mp3")

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
	
func end():
	bella._fade_in.emit()
	$"/root/sfx".play("tip")
	
	print("Timer called...")
	
	var timer = get_tree().create_timer(1.5)
	await timer.timeout
	
	print("Timeout!")
	
	_load.change_scene(_sgt.scene_title)
