extends Node

## Play a sound. Helps with the Dialogue Manager.
func play(sound: String, pitch: float = 1.0, volume: float = 1.0):
	get_node(sound).pitch_scale = pitch
	get_node(sound).volume_db = volume
	get_node(sound).play()
