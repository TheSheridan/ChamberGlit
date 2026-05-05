# This is the minimal template for a normal map.
extends Node2D


@onready var _sgt = $/root/auto_singleton
@onready var _sfx = $/root/sfx

@onready var bella = $CharacterBella
@onready var balloon = $CharacterBella/ExampleBalloon

var big_block_in_hole: bool = false
var small_block_in_hole: bool = false
var see_label_switch: bool = false

var tween: Tween


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.DARK_OLIVE_GREEN)
	bella._fade_out.emit()
	
	$Label.text = "Moving blocks :3"

func _process(_delta: float) -> void:
	_sgt.handle_dialog(bella, balloon)
	
	print("final_cam_position: " + str($CameraMarker.position - $CharacterBella.position)
		+ ", distance: " + str($CameraMarker.position.distance_to($CharacterBella.position)))
	
	#if not see_label_switch:
		#see_label()
	
	#if big_block_in_hole and small_block_in_hole:
		#print("Both blocks are in their holes.")

func see_label():
	var bella_cam_position: Vector2 = $CharacterBella/Camera.position
	var final_cam_position: Vector2 = $CameraMarker.position - $CharacterBella.position
	var duration: float = 0.5
	
	#print("final_cam_position == " + str(final_cam_position))
	
	bella.stand_still = true
	$Label.text = "Blocks moved! 0w0"
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($CharacterBella/Camera, "position", final_cam_position, duration)
	
	$CameraTimer.start(duration * 2)
	await $CameraTimer.timeout
	
	print("Timer 1 finished.")
	tween.stop()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($CharacterBella/Camera, "position", Vector2.ZERO, duration)
	
	$CameraTimer.start(duration)
	await $CameraTimer.timeout
	
	bella.stand_still = false
	see_label_switch = true
	

func _on_big_hole_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("big_block"):
		print("The big block is in the hole!")
		
		_sfx.play("tip", 0.9)
		$BigBlock.lock_position = true
		
		big_block_in_hole = true

		if big_block_in_hole and small_block_in_hole:		
			see_label()

func _on_small_hole_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("small_block"):
		print("The small block is in the hole!")
		
		_sfx.play("tip", 1.5)
		$SmallBlock.lock_position = true
		
		small_block_in_hole = true
		
		if big_block_in_hole and small_block_in_hole:		
			see_label()
