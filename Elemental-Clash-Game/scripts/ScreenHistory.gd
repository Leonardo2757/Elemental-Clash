extends Control

@onready var _lbl_title : Label          = $VBox/LblTitle
@onready var _list      : VBoxContainer  = $VBox/Scroll/List
@onready var _btn_back  : Button         = $VBox/BtnBack

func _ready() -> void:
	_btn_back.pressed.connect(_on_back)

func load_player(player_name: String) -> void:
	_lbl_title.text = "Historial de: " + player_name
	for c in _list.get_children():
		c.queue_free()

	var history = DatabaseManager.get_player_history(player_name)
	if history.is_empty():
		var l = Label.new()
		l.text = "Sin partidas registradas."
		_list.add_child(l)
		return

	var header = Label.new()
	header.text = "Fecha              | Rival              | Resultado | Turnos"
	_list.add_child(header)

	for s in history:
		var rival = s.get("p2", "?") if s.get("p1", "") == player_name else s.get("p1", "?")
		var won = s.get("winner", "") == player_name
		var date_str = s.get("date", "?")
		if date_str.length() > 19:
			date_str = date_str.substr(0, 19)
		var result_str = "VICTORIA" if won else "DERROTA"
		var turns_val = s.get("turns", 0)
		var row = Label.new()
		row.text = "%s | %s | %s | %d" % [date_str, rival, result_str, turns_val]
		if won:
			row.add_theme_color_override("font_color", Color("63a520"))
		else:
			row.add_theme_color_override("font_color", Color("e8593c"))
		_list.add_child(row)

func _on_back() -> void:
	get_parent().get_parent().back_to_menu()
