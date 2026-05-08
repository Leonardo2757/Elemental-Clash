extends PanelContainer
class_name CardNode

signal card_clicked(card_data: CardData, player_owner: int)

@onready var _label_name    : Label = $VBox/LabelName
@onready var _label_atk     : Label = $VBox/LabelAtk
@onready var _label_desc    : Label = $VBox/LabelDesc
@onready var _texture : TextureRect = $TextureRect

var card_data   : CardData = null
var player_owner: int      = 1
var selectable  : bool     = false

func setup(data: CardData, owner_player: int, can_select: bool = true) -> void:
	card_data    = data
	player_owner = owner_player
	selectable   = can_select
	_refresh()

func _refresh() -> void:
	if card_data == null: return
	_label_name.text    = card_data.card_name
	_label_desc.text    = card_data.description

	if card_data.is_special():
		_label_atk.text = "ESPECIAL"
	else:
		_label_atk.text = "%d" % card_data.attack

	var sb = StyleBoxFlat.new()
	sb.bg_color        = card_data.color.darkened(0.5)
	sb.border_color    = card_data.color
	sb.border_width_left   = 3
	sb.border_width_right  = 3
	sb.border_width_top    = 3
	sb.border_width_bottom = 3
	sb.corner_radius_top_left     = 8
	sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8
	sb.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", sb)
	
	match card_data.element:
		CardData.Element.FIRE:
			_texture.texture = load("res://assets/cards/fire.png")
		CardData.Element.WATER:
			_texture.texture = load("res://assets/cards/water.png")
		CardData.Element.EARTH:
			_texture.texture = load("res://assets/cards/earth.png")
		CardData.Element.LIGHTNING:
			_texture.texture = load("res://assets/cards/lightning.png")
		CardData.Element.SPECIAL:
			_texture.texture = load("res://assets/cards/special.png")

func set_selected(v: bool) -> void:
	if v:
		var sb = get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			sb.border_width_left   = 5
			sb.border_width_right  = 5
			sb.border_width_top    = 5
			sb.border_width_bottom = 5
			sb.border_color        = Color.WHITE
	else:
		_refresh()

func _gui_input(event: InputEvent) -> void:
	if selectable and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_clicked.emit(card_data, player_owner)
			AudioManager.play_sfx_select()

func flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED,  0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func animate_select() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 15, 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y,      0.15).set_ease(Tween.EASE_IN)
