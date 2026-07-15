extends StaticBody2D

@onready var _sgt = $"/root/auto_singleton"

func _ready() -> void:
	# Change to _process() if sucks checking once... unless it lags a lot in that function
	if _sgt.flag_artifact_ball:
		queue_free()
