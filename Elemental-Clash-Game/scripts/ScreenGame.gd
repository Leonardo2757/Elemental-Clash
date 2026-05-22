extends Control

@onready var _focus_sprite : TextureRect = $FocusSprite
@onready var _focus_banner : TextureRect = $FocusBanner

@onready var _lbl_turn      : Label     = $VBox/TopBar/LblTurn
@onready var _lbl_weather   : Label     = $VBox/TopBar/LblWeather

@onready var _lbl_p2_name   : Label     = $VBox/TopArea/LblP2Name
@onready var _bar_p2        : ProgressBar = $VBox/TopArea/HBoxHP2/BarP2
@onready var _lbl_p2_hp     : Label     = $VBox/TopArea/HBoxHP2/LblP2Hp
@onready var _hand_p2       : HBoxContainer = $VBox/TopArea/HandP2
@onready var _lbl_p2_status : Label     = $VBox/TopArea/LblP2Status

@onready var _combat_zone   : HBoxContainer = $VBox/CombatZone
@onready var _lbl_result    : Label     = $VBox/LblResult
@onready var _sprite_p1     : AnimatedSprite2D = $VBox/CombatZone/SpriteP1
@onready var _sprite_p2     : AnimatedSprite2D = $VBox/CombatZone/SpriteP2

@onready var _lbl_p1_name   : Label     = $VBox/BottomArea/LblP1Name
@onready var _bar_p1        : ProgressBar = $VBox/BottomArea/HBoxHP1/BarP1
@onready var _lbl_p1_hp     : Label     = $VBox/BottomArea/HBoxHP1/LblP1Hp
@onready var _hand_p1       : HBoxContainer = $VBox/BottomArea/HandP1
@onready var _lbl_p1_status : Label     = $VBox/BottomArea/LblP1Status

@onready var _lbl_autosave  : Label     = $LblAutosave

const CARD_SCENE = preload("res://scenes/CardNode.tscn")
const P1_FOCUS = preload("res://assets/P1/P1_FOCUS.png")
const P2_FOCUS = preload("res://assets/P2/P2_FOCUS.png")
const FOCUS_BANNER = preload("res://assets/banner.png")

var _p1_card_nodes: Array[CardNode] = []
var _p2_card_nodes: Array[CardNode] = []

func _ready() -> void:
	GameManager.hands_updated.connect(_refresh_hands)
	GameManager.turn_resolved.connect(_on_turn_resolved)
	GameManager.hp_changed.connect(_on_hp_changed)
	GameManager.state_changed.connect(_on_state)
	SaveManager.autosave_done.connect(_on_autosave)
	_lbl_autosave.visible = false
	_lbl_result.text = ""
	_start_idle_animation()
	# Centrar manos
	_hand_p1.alignment = BoxContainer.ALIGNMENT_CENTER
	_hand_p2.alignment = BoxContainer.ALIGNMENT_CENTER
	
	_focus_sprite.texture = P1_FOCUS
	_focus_sprite.size = Vector2(250, 300)
	_focus_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_focus_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_focus_sprite.visible = false
	_focus_sprite.modulate = Color(1, 1, 1, 1)


func _start_idle_animation() -> void:
	if _sprite_p1:
		_sprite_p1.play("idle")
	if _sprite_p2:
		_sprite_p2.play("idle")

func _on_state(s: GameManager.GameState) -> void:
	if s == GameManager.GameState.SELECTING:
		_refresh_ui()
		_lbl_result.text = ""
	elif s == GameManager.GameState.REVEALING:
		_show_reveals()

func _refresh_ui() -> void:
	_lbl_p1_name.text = GameManager.p1_name
	_lbl_p2_name.text = GameManager.p2_name
	_lbl_turn.text    = "Turno %d" % GameManager.turn
	var wd = APIManager.get_weather()
	_lbl_weather.text = "Clima: %s — Bonus: %s +%d" % [
		wd.get("description",""),
		wd.get("bonus_element",""),
		wd.get("bonus_dmg",0)
	]
	_on_hp_changed(GameManager.p1_hp, GameManager.p2_hp)
	_refresh_hands()
	_lbl_p1_status.text = "P1:  A / D = navegar  |  F = seleccionar"
	_lbl_p2_status.text = "P2:  ← → = navegar  |  Enter = seleccionar"

func _refresh_hands() -> void:
	for c in _p1_card_nodes: c.queue_free()
	for c in _p2_card_nodes: c.queue_free()
	_p1_card_nodes.clear(); _p2_card_nodes.clear()

	var can_p1 = not GameManager.p1_confirmed
	var can_p2 = not GameManager.p2_confirmed

	for card in GameManager.p1_hand:
		var node = CARD_SCENE.instantiate() as CardNode
		_hand_p1.add_child(node)
		node.setup(card, 1, can_p1)
		node.card_clicked.connect(_on_card_clicked)
		_p1_card_nodes.append(node)

	for card in GameManager.p2_hand:
		var node = CARD_SCENE.instantiate() as CardNode
		_hand_p2.add_child(node)
		node.setup(card, 2, can_p2)
		node.card_clicked.connect(_on_card_clicked)
		_p2_card_nodes.append(node)

func _on_card_clicked(card: CardData, player: int) -> void:
	GameManager.player_select(player, card)
	if player == 1:
		_lbl_p1_status.text = GameManager.p1_name + ": carta seleccionada!"
		for n in _p1_card_nodes:
			n.selectable = false
			if n.card_data == card: n.set_selected(true)
		AudioManager.play_sfx_confirm()
	else:
		_lbl_p2_status.text = GameManager.p2_name + ": carta seleccionada!"
		for n in _p2_card_nodes:
			n.selectable = false
			if n.card_data == card: n.set_selected(true)
		AudioManager.play_sfx_confirm()

func _show_reveals() -> void:
	if GameManager.p1_selected and GameManager.p1_selected.is_special():
		AudioManager.play_special()
	elif GameManager.p1_selected:
		AudioManager.play_magic()

	if GameManager.p2_selected and GameManager.p2_selected.is_special():
		AudioManager.play_special()
	elif GameManager.p2_selected:
		AudioManager.play_magic()

	var dmg1 = GameManager.p1_selected.attack if GameManager.p1_selected else 0
	var dmg2 = GameManager.p2_selected.attack if GameManager.p2_selected else 0

	if dmg1 > dmg2:
		AudioManager.play_win_male()
		_play_focus_animation(1)
	elif dmg2 > dmg1:
		AudioManager.play_win_female()
		_play_focus_animation(2)

	_sprite_p1.play("attack")
	_sprite_p2.play("attack")
	await _sprite_p1.animation_finished
	_sprite_p1.play("idle")
	_sprite_p2.play("idle")

func _on_turn_resolved(result: Dictionary) -> void:
	var txt = ""
	if result.p1_shielded: txt += GameManager.p1_name + " bloqueo!\n"
	if result.p2_shielded: txt += GameManager.p2_name + " bloqueo!\n"
	txt += "Danio a %s: %d  |  Danio a %s: %d" % [
		GameManager.p1_name, result.dmg_to_p1,
		GameManager.p2_name, result.dmg_to_p2
	]
	if result.round_winner == 1:
		txt += "\n>> " + GameManager.p1_name + " gana la ronda!"
		AudioManager.play_sfx_win()
	elif result.round_winner == 2:
		txt += "\n>> " + GameManager.p2_name + " gana la ronda!"
		AudioManager.play_sfx_win()
	else:
		txt += "\n>> Empate de ronda"
	_lbl_result.text = txt

func _on_hp_changed(hp1: int, hp2: int) -> void:
	_lbl_p1_hp.text = "%s  HP: %d / %d" % [GameManager.p1_name, hp1, GameManager.STARTING_HP]
	_lbl_p2_hp.text = "%s  HP: %d / %d" % [GameManager.p2_name, hp2, GameManager.STARTING_HP]
	_bar_p1.value   = float(hp1) / float(GameManager.STARTING_HP) * 100.0
	_bar_p2.value   = float(hp2) / float(GameManager.STARTING_HP) * 100.0
	# Color de barra segun HP
	var p1_fill = hp1 / float(GameManager.STARTING_HP)
	var p2_fill = hp2 / float(GameManager.STARTING_HP)
	_bar_p1.modulate = Color.GREEN if p1_fill > 0.5 else (Color.YELLOW if p1_fill > 0.25 else Color.RED)
	_bar_p2.modulate = Color.GREEN if p2_fill > 0.5 else (Color.YELLOW if p2_fill > 0.25 else Color.RED)
	if hp1 < 10: AudioManager.play_sfx_damage()
	if hp2 < 10: AudioManager.play_sfx_damage()

func _on_autosave() -> void:
	_lbl_autosave.text    = "Guardado automaticamente"
	_lbl_autosave.visible = true
	var t = get_tree().create_timer(2.0)
	t.timeout.connect(func(): _lbl_autosave.visible = false)

# ── Keyboard navigation ───────────────────────────────────────────────────────

var _p1_cursor := 0
var _p2_cursor := 0

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not visible: return
	if GameManager.state != GameManager.GameState.SELECTING: return
	if event.pressed:
		if event.keycode == KEY_A:
			_p1_cursor = max(0, _p1_cursor - 1)
			_highlight_cursor(1)
		elif event.keycode == KEY_D:
			_p1_cursor = min(GameManager.p1_hand.size() - 1, _p1_cursor + 1)
			_highlight_cursor(1)
		elif event.keycode == KEY_F:
			if not GameManager.p1_confirmed and _p1_card_nodes.size() > _p1_cursor:
				_on_card_clicked(GameManager.p1_hand[_p1_cursor], 1)
		elif event.keycode == KEY_LEFT:
			_p2_cursor = max(0, _p2_cursor - 1)
			_highlight_cursor(2)
		elif event.keycode == KEY_RIGHT:
			_p2_cursor = min(GameManager.p2_hand.size() - 1, _p2_cursor + 1)
			_highlight_cursor(2)
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if not GameManager.p2_confirmed and _p2_card_nodes.size() > _p2_cursor:
				_on_card_clicked(GameManager.p2_hand[_p2_cursor], 2)

func _highlight_cursor(player: int) -> void:
	var nodes  = _p1_card_nodes if player == 1 else _p2_card_nodes
	var cursor = _p1_cursor     if player == 1 else _p2_cursor
	for i in nodes.size():
		nodes[i].modulate = Color.YELLOW if i == cursor else Color.WHITE

func _play_focus_animation(player: int) -> void:
	_focus_sprite.texture = P1_FOCUS if player == 1 else P2_FOCUS
	_focus_sprite.size = Vector2(250, 350)
	_focus_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_focus_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	_focus_banner.texture = FOCUS_BANNER
	_focus_banner.size = Vector2(1280, 220)
	_focus_banner.stretch_mode = TextureRect.STRETCH_SCALE
	_focus_banner.position = Vector2(178, 320)
	_focus_banner.visible = true
	_focus_banner.modulate = Color(1, 1, 1, 0)

	var start_x = -260.0 if player == 1 else 1280.0
	var end_x   = 1280.0 if player == 1 else -260.0
	var center_x = 515.0
	var center_y = 185.0

	_focus_sprite.position = Vector2(start_x, center_y)
	_focus_sprite.visible = true
	_focus_sprite.modulate = Color(1, 1, 1, 0)

	# Fase 1: entran juntos en paralelo
	var tween = create_tween().set_parallel(true)
	tween.tween_property(_focus_banner, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.tween_property(_focus_sprite, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.tween_property(_focus_sprite, "position:x", center_x, 0.35).set_ease(Tween.EASE_OUT)
	await tween.finished

	# Pausa en el centro
	await get_tree().create_timer(0.4).timeout

	# Fase 2: salen juntos en paralelo
	var tween2 = create_tween().set_parallel(true)
	tween2.tween_property(_focus_sprite, "position:x", end_x, 0.3).set_ease(Tween.EASE_IN)
	tween2.tween_property(_focus_sprite, "modulate", Color(1, 1, 1, 0), 0.3)
	tween2.tween_property(_focus_banner, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween2.finished

	_focus_sprite.visible = false
	_focus_banner.visible = false
