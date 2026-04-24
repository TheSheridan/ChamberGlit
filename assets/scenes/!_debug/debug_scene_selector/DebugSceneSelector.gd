extends Control


@onready var _fade = get_node('/root/auto_fade')
@onready var _load = get_node('/root/auto_load')

var scene_count: int = 0

var scene_names: Array = [
	"Logo ",
	"Menú principal",
	"Mapa - Cueva 1 (P1)",
	"a",
]

# (ಠ_ಠ)
var scene_paths: Array = [
	"res://assets/scenes/debug_scene_selector/DebugSceneSelector.tscn",
	"res://assets/scenes/scn_mainMenu/scn_mainMenu.tscn",
	"res://assets/scenes/scn_Title0/scn_Title0.tscn",
	"res://assets/scenes/scn_logo/scn_logo.tscn",
	"res://assets/scenes/scn_logo_lite/scn_logo_lite.tscn",
	"res://assets/scenes/maps/map_cave1_r2/map_cave1_r2.tscn",
	"res://assets/scenes/maps/map_cave1_r4/map_cave1_r4.tscn",
	"res://assets/scenes/maps/map_cave1_r3/map_cave1_r3.tscn",
	"res://assets/scenes/maps/map_cave1_r1/map_cave1_r1.tscn",
	"res://assets/scenes/maps/map_bellahouse/map_bellahouse.tscn",
	"res://assets/scenes/battles/btl_test_1/btl_test_1.tscn",
	"res://assets/nodes/chr_bella/chr_bella.tscn",
	"res://assets/nodes/chr_bell/chr_bell.tscn",
	"res://assets/nodes/chr_collisionslope.tscn",
	"res://assets/nodes/chr_collisionslope_2.tscn",
	"res://assets/nodes/chr_collisionblock.tscn",
	"res://assets/scenes/scn_menu_settings/scn_menu_settings.tscn",
	"res://assets/nodes/vfx_snowing/vfx_snowing.tscn",
	"res://assets/scenes/maps/map_cave1_outside/map_cave1_outside.tscn",
	"res://assets/scenes/debug_DialogTest/dialog.tscn",
	"res://assets/autoload/n_animLoading/n_animLoading.tscn",
	"res://assets/autoload/auto_fade.tscn",
	"res://assets/scenes/maps/map_test_dialog/chr_dialogtest/chr_dialogtest.tscn",
	"res://assets/scenes/maps/map_test_dialog/map_test_dialog.tscn",
	"res://assets/scenes/scn_menu_credits/scn_menu_credits.tscn",
	"res://assets/autoload/sfx.tscn",
	"res://assets/scenes/scn_menu_jukebox/scn_menu_jukebox.tscn",
	"res://assets/scenes/scn_menu_extras/scn_menu_extras.tscn",
	"res://assets/scenes/scn_mainMenu/particles.tscn",
	"res://assets/scenes/maps/map_town1/map_town1.tscn",
	"res://assets/scenes/maps/map_test_moveNormal/map_test_moveNormal.tscn",
	"res://assets/nodes/node_moveArrow/node_moveArrow.tscn",
	"res://assets/nodes/chr_bullet/chr_bullet.tscn",
	"res://assets/autoload/auto_load.tscn",
]

var result


func _ready() -> void:
	_fade._out.emit()

	while scene_count < scene_paths.size():
		make_button(scene_paths[scene_count], scene_paths[scene_count])
		scene_count += 1

	#make_button()

func _process(delta: float) -> void:
	var mouse_y = get_viewport().get_mouse_position().y
	var button_box_height = $Margin/Ratio/ButtonVBox.size.y

	#print(get_viewport().get_mouse_position())
	result = -mouse_y * ($Margin.size.y / button_box_height * 3)
	print(result)
	$Margin/Ratio/ButtonVBox.position.y = result + 600

func make_button(text, scene_to_change):
	var button = Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	button.pressed.connect(func(): _load.change_scene(scene_to_change), CONNECT_ONE_SHOT)
	
	$Margin/Ratio/ButtonVBox.add_child(button)
