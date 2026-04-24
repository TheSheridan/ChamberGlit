extends Control

func _ready():
	$ExampleBalloon.start_from_cue = "start"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if not $ExampleBalloon.after_closing:
			if not $ExampleBalloon.is_running_dialog:
				$ExampleBalloon.start()
		else:
			$ExampleBalloon.after_closing = false
