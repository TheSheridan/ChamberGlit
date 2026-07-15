extends Node2D

var bella_prev_position: Vector2

@onready var bella = $"../../../CharacterBella"
@onready var bella_ray = $"../../../CharacterBella/Ray"

func _process(delta: float) -> void:
	bella_prev_position = bella.position
	
	if bella.get_input() != Vector2.ZERO and bella.position == bella_prev_position \
	and not bella_ray.is_colliding():
		#print("Bella pos: " + str(bella.position) + ", prev pos: " + str(bella_prev_position))
		$PlayerMarker.position += bella.get_input()
