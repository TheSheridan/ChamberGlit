extends Node

signal fade_finished

func _ready() -> void:
	#play_music("bgm_chamber.mp3")
	pass

## Play a music track. It must be on res://assets/audio.
func play_music(track: String, pitch: float = 1.0, volume: float = 0.0):
	var stream_file: AudioStream = load("res://assets/audio/" + track)
	print("stream_file")
	
	if $Audio.stream != stream_file:
		$Audio.stream = stream_file
	if not $Audio.playing:
		$Audio.playing = true

func play_bg(track: String, pitch: float = 1.0, volume: float = 0.0):
	var stream_file: AudioStream = load("res://assets/audio/" + track)
	print("stream_file")
	
	if $Background.stream != stream_file:
		$Background.stream = stream_file
	if not $Background.playing:
		$Background.playing = true

func pause():
	$Audio.playing = false

func resume():
	$Audio.playing = true

func stop_music():
	$Audio.stop()

func fade_in(time: float = 0.25, volume: float = 0):
	var tween = create_tween()
	tween.tween_property($Audio, "volume_db", volume, time)
	if tween.finished: fade_finished.emit()

func fade_out(time: float = 0.25):
	var tween = create_tween()
	tween.tween_property($Audio, "volume_db", -50, time)
	if tween.finished: fade_finished.emit()
