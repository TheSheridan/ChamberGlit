extends CharacterBody2D


@onready var tile_size: float = $Collision.shape.size.x

@onready var bella = get_parent().get_node("CharacterBella")
@onready var bella_raycast = get_parent().get_node("CharacterBella/Ray")

@onready var tween: Tween

var can_interact: bool = false
@export var lock_position: bool = false


func _process(delta: float) -> void:
	if can_interact:
		if Input.is_action_just_pressed("ui_accept"):
			move()
			$MoveSound.play()
	
	if lock_position:
		can_interact = false
	

func move():
	var move_position = position + bella_raycast.target_position.normalized() * tile_size
	
	# Bella is frozen during the anim to avoid getting the block stuck while moving
	bella.stand_still = true
	tween = create_tween()

	# Start moving	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", move_position, 0.2)
	
	# Clean all
	await tween.finished
	tween.kill()
	bella.stand_still = false

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not lock_position:
			can_interact = true

func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not lock_position:
			can_interact = false
