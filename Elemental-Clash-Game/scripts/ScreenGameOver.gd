extends Control

@onready var _lbl_winner    : Label  = $VBox/LblWinner
@onready var _lbl_stats     : Label  = $VBox/LblStats
@onready var _lbl_saving    : Label  = $VBox/LblSaving
@onready var _btn_rematch   : Button = $VBox/HBox/BtnRematch
@onready var _btn_menu      : Button = $VBox/HBox/BtnMenu
@onready var _btn_leaders   : Button = $VBox/HBox/BtnLeaderboard

func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)
	_btn_rematch.pressed.connect(_on_rematch)
	_btn_menu.pressed.connect(_on_menu)
	_btn_leaders.pressed.connect(_on_leaders)
	APIManager.post_done.connect(_on_post_done)
	_lbl_saving.visible = false

func _on_game_over(winner: String, loser: String) -> void:
	_lbl_winner.text = "GANADOR: " + winner
	_lbl_stats.text  = "Turnos jugados: %d\n%s HP: %d  |  %s HP: %d" % [
		GameManager.turn,
		GameManager.p1_name, GameManager.p1_hp,
		GameManager.p2_name, GameManager.p2_hp
	]
	_lbl_saving.visible = true
	_lbl_saving.text    = "Guardando resultados..."
	AudioManager.play_sfx_win()

func _on_post_done(_success: bool) -> void:
	_lbl_saving.text    = "Resultados sincronizados."
	await get_tree().create_timer(1.5).timeout
	_lbl_saving.visible = false

func _on_rematch() -> void:
	AudioManager.play_sfx_confirm()
	GameManager.start_game(GameManager.p1_name, GameManager.p2_name)

func _on_menu() -> void:
	AudioManager.play_sfx_confirm()
	get_parent().get_parent().back_to_menu()

func _on_leaders() -> void:
	get_parent().get_parent().show_leaderboard()
