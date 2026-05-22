extends Control

@onready var _edit_p1       : LineEdit = $VBox/HBox/VBoxP1/EditP1
@onready var _edit_p2       : LineEdit = $VBox/HBox/VBoxP2/EditP2
@onready var _lbl_info      : Label   = $VBox/LblInfo
@onready var _btn_start     : Button  = $VBox/BtnStart
@onready var _btn_back      : Button  = $VBox/BtnBack
@onready var _lbl_loading   : Label   = $VBox/LblLoading
@onready var _btn_history_p1: Button  = $VBox/HBox/VBoxP1/BtnHistP1
@onready var _btn_history_p2: Button  = $VBox/HBox/VBoxP2/BtnHistP2
@onready var _bg_anim : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_bg_anim.play("default")
	_btn_start.pressed.connect(_on_start)
	_btn_back.pressed.connect(_on_back)
	_btn_history_p1.pressed.connect(func(): get_parent().get_parent().show_history(_edit_p1.text))
	_btn_history_p2.pressed.connect(func(): get_parent().get_parent().show_history(_edit_p2.text))
	_lbl_loading.visible = false
	# Actualizar texto de botones de historial
	_btn_history_p1.text = "Historial de Jugador 1"
	_btn_history_p2.text = "Historial de Jugador 2"

func _on_start() -> void:
	var n1 = _edit_p1.text.strip_edges()
	var n2 = _edit_p2.text.strip_edges()
	if n1 == "" or n2 == "":
		_lbl_info.text = "Por favor ingresa ambos nombres."
		AudioManager.play_sfx_error()
		return
	if n1 == n2:
		_lbl_info.text = "Los nombres deben ser diferentes."
		AudioManager.play_sfx_error()
		return

	_lbl_loading.visible = true
	_lbl_loading.text    = "Cargando partida..."
	await get_tree().process_frame

	var p1 = DatabaseManager.get_or_create_player(n1)
	var p2 = DatabaseManager.get_or_create_player(n2)
	_lbl_info.text = "%s: %d victorias  |  %s: %d victorias" % [
		p1.name, int(p1.wins), p2.name, int(p2.wins)
	]

	AudioManager.play_sfx_confirm()
	GameManager.start_game(n1, n2)
	_lbl_loading.visible = false

func _on_back() -> void:
	get_parent().get_parent().back_to_menu()
