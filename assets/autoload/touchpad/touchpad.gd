extends CanvasLayer


signal _in
signal _out

@export var transparency: float = 1.0


func _process(_delta: float) -> void:
	$CanvasLayer.modulate.a = transparency

func _on_button_a_button_down() -> void:
	Input.action_press("ui_accept")

func _on_button_a_button_up() -> void:
	Input.action_release("ui_accept")

func _on_button_b_button_down() -> void:
	Input.action_press("ui_cancel")

func _on_button_b_button_up() -> void:
	Input.action_release("ui_cancel")

func _on_button_c_button_down() -> void:
	Input.action_press("ui_select")

func _on_button_c_button_up() -> void:
	Input.action_release("ui_select")

func _on__in() -> void:
	$AnimationPlayer.play("show")
	await $AnimationPlayer.animation_finished
	transparency = 1

func _on__out() -> void:
	$AnimationPlayer.play("hide")
	await $AnimationPlayer.animation_finished
	transparency = 0
