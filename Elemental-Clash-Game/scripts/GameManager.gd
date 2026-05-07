extends Node

signal state_changed(new_state: GameState)
signal turn_resolved(result: Dictionary)
signal game_over(winner_name: String, loser_name: String)
signal hands_updated()
signal hp_changed(p1_hp: int, p2_hp: int)

enum GameState { MENU, PROFILES, LOADING, SELECTING, REVEALING, RESULT, GAME_OVER, SETTINGS, LEADERBOARD }

const ADVANTAGE = {
	CardData.Element.FIRE:      { "beats": CardData.Element.EARTH,  "loses": CardData.Element.WATER },
	CardData.Element.WATER:     { "beats": CardData.Element.FIRE,   "loses": CardData.Element.EARTH },
	CardData.Element.EARTH:     { "beats": CardData.Element.WATER,  "loses": CardData.Element.FIRE  },
	CardData.Element.LIGHTNING: { "beats": CardData.Element.WATER,  "loses": CardData.Element.EARTH },
}
const BONUS_DAMAGE  := 3
const STARTING_HP   := 20
const HAND_SIZE     := 5

var state: GameState = GameState.MENU

var p1_name:  String = "Jugador 1"
var p2_name:  String = "Jugador 2"
var p1_hp:    int    = STARTING_HP
var p2_hp:    int    = STARTING_HP

var p1_deck:  Array[CardData] = []
var p2_deck:  Array[CardData] = []
var p1_hand:  Array[CardData] = []
var p2_hand:  Array[CardData] = []

var p1_selected: CardData = null
var p2_selected: CardData = null

var p1_confirmed: bool = false
var p2_confirmed: bool = false

var turn: int  = 0
var last_result: Dictionary = {}
var weather_bonus_element: String = "FIRE"
var weather_bonus_dmg:     int    = 2

# ── Start / Restart ────────────────────────────────────────────────────────────

func start_game(name1: String, name2: String) -> void:
	p1_name = name1
	p2_name = name2
	p1_hp   = STARTING_HP
	p2_hp   = STARTING_HP
	turn    = 0
	last_result = {}
	p1_deck = DeckBuilder.build_deck()
	p2_deck = DeckBuilder.build_deck()
	p1_hand.clear(); p2_hand.clear()
	p1_selected = null; p2_selected = null
	p1_confirmed = false; p2_confirmed = false
	for _i in HAND_SIZE:
		_draw(1); _draw(2)

	# Apply weather bonuses
	var wd = APIManager.get_weather()
	weather_bonus_element = wd.get("bonus_element", "FIRE")
	weather_bonus_dmg     = wd.get("bonus_dmg",     2)

	DatabaseManager.get_or_create_player(p1_name)
	DatabaseManager.get_or_create_player(p2_name)

	_set_state(GameState.SELECTING)
	SaveManager.start_autosave()

func _draw(player: int) -> void:
	if player == 1 and p1_deck.size() > 0:
		p1_hand.append(p1_deck.pop_front())
	elif player == 2 and p2_deck.size() > 0:
		p2_hand.append(p2_deck.pop_front())

# ── Selection ─────────────────────────────────────────────────────────────────

func player_select(player: int, card: CardData) -> void:
	if state != GameState.SELECTING: return
	if player == 1 and not p1_confirmed:
		p1_selected  = card
		p1_confirmed = true
		AudioManager.play_sfx_select()
	elif player == 2 and not p2_confirmed:
		p2_selected  = card
		p2_confirmed = true
		AudioManager.play_sfx_select()
	if p1_confirmed and p2_confirmed:
		_set_state(GameState.REVEALING)
		get_tree().create_timer(0.6).timeout.connect(resolve_turn)

# ── Resolution ────────────────────────────────────────────────────────────────

func resolve_turn() -> void:
	if state != GameState.REVEALING: return
	turn += 1

	var result = _calculate(p1_selected, p2_selected)
	p1_hp = max(0, p1_hp - result.dmg_to_p1)
	p2_hp = max(0, p2_hp - result.dmg_to_p2)
	hp_changed.emit(p1_hp, p2_hp)

	p1_hand.erase(p1_selected)
	p2_hand.erase(p2_selected)

	# Draw replacement cards
	_draw(1); _draw(2)
	hands_updated.emit()

	last_result = result
	last_result["p1_hp"] = p1_hp
	last_result["p2_hp"] = p2_hp
	last_result["turn"]  = turn
	turn_resolved.emit(last_result)

	if p1_hp <= 0 or p2_hp <= 0 or (p1_hand.is_empty() and p2_hand.is_empty()):
		_set_state(GameState.GAME_OVER)
		_finish_game()
	else:
		p1_selected  = null; p2_selected  = null
		p1_confirmed = false; p2_confirmed = false
		_set_state(GameState.SELECTING)

func _calculate(c1: CardData, c2: CardData) -> Dictionary:
	var dmg1 := c1.attack
	var dmg2 := c2.attack

	# --- special cards ---
	var c1_eff = c1.element
	var c2_eff = c2.element

	if c1.special_type == CardData.SpecialType.MIRROR:
		c1_eff = c2.element; dmg1 = c2.attack
	if c2.special_type == CardData.SpecialType.MIRROR:
		c2_eff = c1.element; dmg2 = c1.attack

	var p1_shielded = c1.special_type == CardData.SpecialType.SHIELD
	var p2_shielded = c2.special_type == CardData.SpecialType.SHIELD

	if c1.special_type == CardData.SpecialType.STORM: dmg1 = 5
	if c2.special_type == CardData.SpecialType.STORM: dmg2 = 5

	# --- elemental advantage ---
	var c1_bonus := 0
	var c2_bonus := 0
	if ADVANTAGE.has(c1_eff) and ADVANTAGE[c1_eff]["beats"] == c2_eff:
		c1_bonus = BONUS_DAMAGE
	if ADVANTAGE.has(c2_eff) and ADVANTAGE[c2_eff]["beats"] == c1_eff:
		c2_bonus = BONUS_DAMAGE

	# --- weather bonus ---
	var wb_str = CardData.Element.keys()[c1_eff] if CardData.Element.keys().size() > int(c1_eff) else ""
	if wb_str == weather_bonus_element: c1_bonus += weather_bonus_dmg
	wb_str = CardData.Element.keys()[c2_eff] if CardData.Element.keys().size() > int(c2_eff) else ""
	if wb_str == weather_bonus_element: c2_bonus += weather_bonus_dmg

	var final_dmg1 = dmg1 + c1_bonus
	var final_dmg2 = dmg2 + c2_bonus

	# --- apply shields ---
	var dmg_to_p2 = 0 if p2_shielded else final_dmg1
	var dmg_to_p1 = 0 if p1_shielded else final_dmg2

	# --- determine winner ---
	var winner_player = 0
	if dmg_to_p2 > dmg_to_p1:  winner_player = 1
	elif dmg_to_p1 > dmg_to_p2: winner_player = 2

	return {
		"c1":           c1,
		"c2":           c2,
		"dmg_p1_dealt": final_dmg1,
		"dmg_p2_dealt": final_dmg2,
		"dmg_to_p1":    dmg_to_p1,
		"dmg_to_p2":    dmg_to_p2,
		"c1_bonus":     c1_bonus,
		"c2_bonus":     c2_bonus,
		"p1_shielded":  p1_shielded,
		"p2_shielded":  p2_shielded,
		"round_winner": winner_player
	}

# ── Game Over ─────────────────────────────────────────────────────────────────

func _finish_game() -> void:
	SaveManager.stop_autosave()
	var winner_name: String
	var loser_name:  String
	if p1_hp > p2_hp:
		winner_name = p1_name; loser_name = p2_name
	elif p2_hp > p1_hp:
		winner_name = p2_name; loser_name = p1_name
	else:
		# tiebreaker: most cards in hand
		winner_name = p1_name if p1_hand.size() >= p2_hand.size() else p2_name
		loser_name  = p2_name if winner_name == p1_name else p1_name

	var session = {
		"p1":          p1_name,
		"p2":          p2_name,
		"p1_hp_final": p1_hp,
		"p2_hp_final": p2_hp,
		"turns":       turn,
		"winner":      winner_name,
		"loser":       loser_name,
		"date":        Time.get_datetime_string_from_system()
	}
	DatabaseManager.save_session(session)
	DatabaseManager.clear_autosave()
	APIManager.post_session_result(session)
	game_over.emit(winner_name, loser_name)

# ── Snapshot (autosave / restore) ─────────────────────────────────────────────

func get_state_snapshot() -> Dictionary:
	return {
		"p1_name": p1_name, "p2_name": p2_name,
		"p1_hp":   p1_hp,   "p2_hp":   p2_hp,
		"turn":    turn,
		"p1_hand": _hand_to_arr(p1_hand),
		"p2_hand": _hand_to_arr(p2_hand),
	}

func restore_from_snapshot(snap: Dictionary) -> void:
	if snap.is_empty(): return
	p1_name = snap.get("p1_name", "J1")
	p2_name = snap.get("p2_name", "J2")
	p1_hp   = snap.get("p1_hp",  STARTING_HP)
	p2_hp   = snap.get("p2_hp",  STARTING_HP)
	turn    = snap.get("turn",   0)
	# hands are rebuilt from names only (simple approach)
	_set_state(GameState.SELECTING)
	SaveManager.start_autosave()

func _hand_to_arr(hand: Array[CardData]) -> Array:
	var out: Array = []
	for c in hand:
		out.append(c.to_dict())
	return out

# ── Util ──────────────────────────────────────────────────────────────────────

func _set_state(s: GameState) -> void:
	state = s
	state_changed.emit(s)
