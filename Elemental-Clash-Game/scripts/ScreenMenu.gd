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
	_lbl_weather.text = "Clima: %s  |  Bonus: %s +%d" % [
		wd.get("description", "..."),
		wd.get("bonus_element", "?"),
		wd.get("bonus_dmg", 0)
	]

func show_resume_button(v: bool) -> void:
	_btn_resume.visible = v

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
	_lbl_weather.text = "Clima: %s  |  Bonus hoy: %s +%d" % [
		data.get("description", ""),
		data.get("bonus_element", ""),
		data.get("bonus_dmg", 0)
	]

func _on_weather_fail() -> void:
	_lbl_weather.text = "Clima: Sin conexion (datos locales)"
