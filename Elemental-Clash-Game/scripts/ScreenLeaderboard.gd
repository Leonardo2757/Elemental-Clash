extends Control

@onready var _list       : VBoxContainer = $VBox/Scroll/List
@onready var _btn_back   : Button        = $VBox/BtnBack
@onready var _lbl_loading: Label         = $VBox/LblLoading

func _ready() -> void:
	_btn_back.pressed.connect(_on_back)

func _on_visibility_changed() -> void:
	if visible:
		_load_leaderboard()

func _load_leaderboard() -> void:
	_lbl_loading.text    = "Cargando tabla..."
	_lbl_loading.visible = true
	for c in _list.get_children(): c.queue_free()
	await get_tree().process_frame

	var lb = DatabaseManager.get_leaderboard()
	if lb.is_empty():
		var lbl = Label.new()
		lbl.text = "Aun no hay partidas registradas."
		_list.add_child(lbl)
	else:
		var header = Label.new()
		header.text = "# | Jugador              | Victorias | Partidas"
		header.add_theme_font_size_override("font_size", 14)
		_list.add_child(header)
		for i in lb.size():
			var p   = lb[i]
			var row = Label.new()
			row.text = "%d  |  %-20s |     %d     |    %d" % [
				i + 1, p.get("name", "?"),
				p.get("wins",  0),
				p.get("games", 0)
			]
			_list.add_child(row)

	_lbl_loading.visible = false

func _on_back() -> void:
	get_parent().get_parent().back_to_menu()
