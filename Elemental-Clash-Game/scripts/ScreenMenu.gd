extends Control

@onready var _btn_play      : Button = $VBox/BtnPlay
@onready var _btn_resume    : Button = $VBox/BtnResume
@onready var _btn_settings  : Button = $VBox/BtnSettings
@onready var _btn_leaders   : Button = $VBox/BtnLeaderboard
@onready var _lbl_weather   : Label  = $VBox/LblWeather

func _ready() -> void:
	_btn_play.pressed.connect(_on_play)
	_btn_resume.pressed.connect(_on_resume)
	_btn_settings.pressed.connect(_on_settings)
	_btn_leaders.pressed.connect(_on_leaderboard)
	_btn_resume.visible = false

	APIManager.api_data_ready.connect(_on_weather)
	APIManager.api_failed.connect(_on_weather_fail)
	var wd = APIManager.get_weather()
	_update_weather_label(wd)

	if DatabaseManager.has_autosave():
		_btn_resume.visible = true

func show_resume_button(v: bool) -> void:
	_btn_resume.visible = v

func _update_weather_label(wd: Dictionary) -> void:
	var element = wd.get("bonus_element", "?")
	var bonus   = wd.get("bonus_dmg", 0)
	var desc    = wd.get("description", "...")
	var icon    = _weather_icon(wd.get("weathercode", 0))
	_lbl_weather.text = "%s %s  |  Elemento favorecido: %s  (+%d DMG)" % [icon, desc, element, bonus]

func _weather_icon(code: int) -> String:
	if code == 0:       return "☀"
	elif code <= 3:     return "⛅"
	elif code <= 49:    return "🌫"
	elif code <= 69:    return "🌧"
	elif code <= 79:    return "❄"
	elif code <= 99:    return "⚡"
	return "🌡"

func _on_play() -> void:
	AudioManager.play_sfx_confirm()
	GameManager._set_state(GameManager.GameState.PROFILES)

func _on_resume() -> void:
	AudioManager.play_sfx_confirm()
	var snap = DatabaseManager.load_autosave()
	if snap.is_empty():
		_btn_resume.visible = false
		return
	SaveManager.restore_session(snap)

func _on_settings() -> void:
	GameManager._set_state(GameManager.GameState.SETTINGS)

func _on_leaderboard() -> void:
	GameManager._set_state(GameManager.GameState.LEADERBOARD)

func _on_weather(data: Dictionary) -> void:
	_update_weather_label(data)

func _on_weather_fail() -> void:
	_lbl_weather.text = "⚠ Sin conexion — usando datos locales"
