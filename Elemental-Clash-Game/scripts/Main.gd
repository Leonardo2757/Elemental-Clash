extends Node

@onready var _screen_menu        : Control = $Screens/ScreenMenu
@onready var _screen_profiles    : Control = $Screens/ScreenProfiles
@onready var _screen_loading     : Control = $Screens/ScreenLoading
@onready var _screen_game        : Control = $Screens/ScreenGame
@onready var _screen_result      : Control = $Screens/ScreenResult
@onready var _screen_gameover    : Control = $Screens/ScreenGameOver
@onready var _screen_settings    : Control = $Screens/ScreenSettings
@onready var _screen_leaderboard : Control = $Screens/ScreenLeaderboard
@onready var _screen_history     : Control = $Screens/ScreenHistory

var _all_screens: Array[Control]

func _ready() -> void:
	_all_screens = [
		_screen_menu, _screen_profiles, _screen_loading,
		_screen_game, _screen_result, _screen_gameover,
		_screen_settings, _screen_leaderboard, _screen_history
	]
	GameManager.state_changed.connect(_on_state_changed)
	_show_only(_screen_menu)

	# Check for interrupted session
	if DatabaseManager.has_autosave():
		_screen_menu.show_resume_button(true)

func _on_state_changed(s: GameManager.GameState) -> void:
	match s:
		GameManager.GameState.PROFILES:     _show_only(_screen_profiles)
		GameManager.GameState.LOADING:      _show_only(_screen_loading)
		GameManager.GameState.SELECTING:    _show_only(_screen_game)
		GameManager.GameState.REVEALING:    _show_only(_screen_game)
		GameManager.GameState.GAME_OVER:    _show_only(_screen_gameover)
		GameManager.GameState.SETTINGS:     _show_only(_screen_settings)
		GameManager.GameState.LEADERBOARD:  _show_only(_screen_leaderboard)

func _show_only(screen: Control) -> void:
	for s in _all_screens:
		s.visible = (s == screen)

func show_leaderboard() -> void:
	_show_only(_screen_leaderboard)

func show_history(player_name: String) -> void:
	_screen_history.load_player(player_name)
	_show_only(_screen_history)

func show_result(data: Dictionary) -> void:
	_screen_result.display(data)
	_show_only(_screen_result)

func back_to_menu() -> void:
	_show_only(_screen_menu)
