extends Node

const SETTINGS_FILE = "user://settings.cfg"

var music_volume: float = 0.8
var sfx_volume: float = 1.0
var fullscreen: bool = false
var api_base_url: String = "https://api.open-meteo.com/v1"
var post_api_url: String = "https://httpbin.org/post"
var autosave_interval: float = 30.0

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SETTINGS_FILE) == OK:
		music_volume    = cfg.get_value("audio",   "music_volume",    0.8)
		sfx_volume      = cfg.get_value("audio",   "sfx_volume",      1.0)
		fullscreen       = cfg.get_value("display", "fullscreen",      false)
		api_base_url    = cfg.get_value("api",     "base_url",        "https://api.open-meteo.com/v1")
		post_api_url    = cfg.get_value("api",     "post_url",        "https://httpbin.org/post")
		autosave_interval = cfg.get_value("game",  "autosave_interval", 30.0)
	_apply_settings()

func save_settings() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("audio",   "music_volume",     music_volume)
	cfg.set_value("audio",   "sfx_volume",       sfx_volume)
	cfg.set_value("display", "fullscreen",       fullscreen)
	cfg.set_value("api",     "base_url",         api_base_url)
	cfg.set_value("api",     "post_url",         post_api_url)
	cfg.set_value("game",    "autosave_interval", autosave_interval)
	cfg.save(SETTINGS_FILE)

func _apply_settings() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))

	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

func set_music_volume(v: float) -> void:
	music_volume = clamp(v, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
		linear_to_db(music_volume))

func set_sfx_volume(v: float) -> void:
	sfx_volume = clamp(v, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx_volume))
