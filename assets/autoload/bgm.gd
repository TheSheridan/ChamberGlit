extends Node

@export var pitch_music: float = 1
@export var volume_db_music: float = 0
var volume_db_music_fade: float

@export var pitch_bg: float = 1
@export var volume_db_bg: float = 0
var volume_db_bg_fade: float

var is_fading_music: bool = false
var is_fading_bg: bool = false

signal fade_finished

func _ready() -> void:
	#play_music("bgm_chamber.mp3")
	pass

func _process(_delta: float) -> void:
	$Audio.pitch_scale = pitch_music
	$Audio.volume_db = volume_db_music + volume_db_music_fade
	
	$Background.pitch_scale = pitch_bg
	$Background.volume_db = volume_db_bg + volume_db_bg_fade

## Play a music track. It must be on res://assets/audio.
func play_music(track: String, pitch: float = 1.0, volume: float = 0.0):
	var stream_file: AudioStream = load("res://assets/audio/" + track)
	print("stream_file")
	
	if $Audio.stream != stream_file:
		$Audio.stream = stream_file
	if not $Audio.playing:
		$Audio.playing = true
		
	# Why it doesn't work...
	pitch_music = pitch
	volume_db_music = volume

func play_bg(track: String, pitch: float = 1.0, volume: float = 0.0):
	var stream_file: AudioStream = load("res://assets/audio/" + track)
	print("stream_file")
	
	if $Background.stream != stream_file:
		$Background.stream = stream_file
	if not $Background.playing:
		$Background.playing = true
		
	pitch_bg = pitch
	volume_db_bg = volume

func pause_music():
	$Audio.playing = false

func resume_music():
	$Audio.playing = true

func stop_music():
	$Audio.stop()

func pause_bg():
	$Background.playing = false

func resume_bg():
	$Background.playing = true
	
func stop_bg():
	$Background.stop()

func fade_in(time: float = 0.25, volume: float = 0):
	var tween = create_tween()
	tween.tween_property(self, "volume_db_music_fade", volume, time)
	if tween.finished: fade_finished.emit()

func fade_out(time: float = 0.25):
	var tween = create_tween()
	tween.tween_property(self, "volume_db_music_fade", -50, time)
	if tween.finished: fade_finished.emit()
	
func fade_in_bg(time: float = 0.25, volume: float = 0):
	var tween = create_tween()
	tween.tween_property(self, "volume_db_bg_fade", volume, time)
	if tween.finished: fade_finished.emit()

func fade_out_bg(time: float = 0.25):
	var tween = create_tween()
	tween.tween_property(self, "volume_db_bg_fade", -50, time)
	if tween.finished: fade_finished.emit()
	
