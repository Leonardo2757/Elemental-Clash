extends Control

@onready var _grid       : GridContainer = $VBox/Scroll/Grid
@onready var _btn_back   : Button        = $VBox/BtnBack
@onready var _lbl_loading: Label         = $VBox/LblLoading

func _ready() -> void:
	_btn_back.pressed.connect(_on_back)
	GameManager.state_changed.connect(_on_state_changed)

func _on_state_changed(s: GameManager.GameState) -> void:
	if s == GameManager.GameState.LEADERBOARD:
		_load_leaderboard()

func _load_leaderboard() -> void:
	_lbl_loading.text    = "Cargando tabla..."
	_lbl_loading.visible = true
	for c in _grid.get_children():
		c.queue_free()

	var lb = DatabaseManager.get_leaderboard()
	if lb.is_empty():
		_lbl_loading.text = "Aun no hay partidas registradas."
		return

	var headers = ["#", "Jugador", "Victorias", "Partidas"]
	var col_widths = [40, 200, 100, 100]

	for i in headers.size():
		var lbl = Label.new()
		lbl.text = headers[i]
		lbl.custom_minimum_size = Vector2(col_widths[i], 0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color("f2a623"))
		lbl.add_theme_font_size_override("font_size", 14)
		_grid.add_child(lbl)

	for i in lb.size():
		var p = lb[i]
		var cols = [
			str(i + 1),
			p.get("name", "?"),
			str(int(p.get("wins", 0))),
			str(int(p.get("games", 0)))
		]
		for j in cols.size():
			var cell = Label.new()
			cell.text = cols[j]
			cell.custom_minimum_size = Vector2(col_widths[j], 0)
			cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_grid.add_child(cell)

	_lbl_loading.visible = false

func _on_back() -> void:
	get_parent().get_parent().back_to_menu()
