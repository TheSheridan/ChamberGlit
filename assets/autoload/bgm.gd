extends AudioStreamPlayer

signal fade_finished

func _ready() -> void:
	#play_music("bgm_chamber.mp3")
	pass

## Play a music track. It must be on res://assets/audio.
func play_music(track: String, pitch: float = 1.0, volume: float = 0.0):
	var stream_file: AudioStream = load("res://assets/audio/" + track)
	
	stream = stream_file
	print(stream)
	#pitch_scale = pitch
	#volume_db = volume
	playing = true

func pause():
	playing = false

func resume():
	playing = true

func stop_music():
	stop()

func fade_in(time: float = 0.25, volume: float = 0):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", volume, time)
	if tween.finished: fade_finished.emit()

func fade_out(time: float = 0.25):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -50, time)
	if tween.finished: fade_finished.emit()
