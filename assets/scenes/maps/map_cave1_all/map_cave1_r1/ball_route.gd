extends Node2D


@onready var _sgt = $"/root/auto_singleton"

func _ready():
	modulate.a = 0

func _process(delta: float) -> void:
	# Change to _process() if sucks checking once... unless it lags a lot in that function
	if _sgt.flag_artifact_ball and $Blocks:
		$Blocks.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _sgt.flag_artifact_ball:
		$AnimationPlayer.play("fade_out")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and _sgt.flag_artifact_ball:
		$AnimationPlayer.play("fade_in")
