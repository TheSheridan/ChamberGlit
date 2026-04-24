extends Node

func play(sound: String, pitch: float = 1.0):
	get_node(sound).pitch_scale = pitch
	get_node(sound).play()
