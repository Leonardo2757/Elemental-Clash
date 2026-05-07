extends Node
# Plays procedurally-generated tones since we have no audio files.
# Replace AudioStreamGenerator usage with real OGG/WAV files if desired.

var _music_player : AudioStreamPlayer
var _sfx_player   : AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)

func play_sfx_confirm() -> void:   _beep(523.0, 0.08)  # C5
func play_sfx_select()  -> void:   _beep(440.0, 0.06)  # A4
func play_sfx_win()     -> void:   _fanfare([523.0, 659.0, 784.0])
func play_sfx_lose()    -> void:   _fanfare([392.0, 330.0, 262.0])
func play_sfx_damage()  -> void:   _beep(220.0, 0.12)
func play_sfx_block()   -> void:   _beep(660.0, 0.07)
func play_sfx_special() -> void:   _fanfare([440.0, 554.0, 659.0, 880.0])
func play_sfx_error()   -> void:   _beep(180.0, 0.15)

func _beep(freq: float, dur: float) -> void:
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 44100.0
	gen.buffer_length = dur
	_sfx_player.stream = gen
	_sfx_player.play()
	# fill buffer with sine wave
	await get_tree().process_frame
	var playback = _sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null: return
	var frames = int(44100.0 * dur)
	for i in frames:
		var t = float(i) / 44100.0
		var envelope = 1.0 - (t / dur)   # fade out
		playback.push_frame(Vector2.ONE * sin(TAU * freq * t) * 0.4 * envelope)

func _fanfare(freqs: Array) -> void:
	for f in freqs:
		_beep(f, 0.10)
		await get_tree().create_timer(0.10).timeout
