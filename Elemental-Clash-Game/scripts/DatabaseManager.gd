extends Node
# NOTE: Uses a JSON file as database fallback since SQLite addon
# must be added by the team. Swap _db_* calls for actual SQLiteWrapper
# once the addon is placed in addons/godot-sqlite/

const DB_PATH = "user://elemental_clash.db.json"

var _data: Dictionary = {
	"players":  {},   # name -> { name, games, wins, losses, created_at }
	"sessions": [],   # list of session dicts
	"autosave": {}    # latest autosave
}

func _ready() -> void:
	_load_db()

# ── Players ──────────────────────────────────────────────────────────────────

func get_or_create_player(player_name: String) -> Dictionary:
	player_name = player_name.strip_edges()
	if player_name == "":
		player_name = "Jugador"
	if not _data.players.has(player_name):
		_data.players[player_name] = {
			"name":       player_name,
			"games":      0,
			"wins":       0,
			"losses":     0,
			"created_at": Time.get_datetime_string_from_system()
		}
		_save_db()
	return _data.players[player_name]

func get_player_history(player_name: String) -> Array:
	var history: Array = []
	for s in _data.sessions:
		if s.get("p1") == player_name or s.get("p2") == player_name:
			history.append(s)
	return history

func get_leaderboard() -> Array:
	var lb: Array = _data.players.values().duplicate()
	lb.sort_custom(func(a, b): return a.wins > b.wins)
	return lb.slice(0, 10)

# ── Sessions ─────────────────────────────────────────────────────────────────

func save_session(session: Dictionary) -> void:
	session["id"]         = _data.sessions.size()
	session["saved_at"]   = Time.get_datetime_string_from_system()
	_data.sessions.append(session)

	# update stats
	for pname in [session.get("p1", ""), session.get("p2", "")]:
		if pname == "": continue
		get_or_create_player(pname)  # ensure exists
		_data.players[pname].games += 1

	var winner = session.get("winner", "")
	if winner != "" and _data.players.has(winner):
		_data.players[winner].wins += 1
	for pname in [session.get("p1", ""), session.get("p2", "")]:
		if pname != "" and pname != winner and _data.players.has(pname):
			_data.players[pname].losses += 1

	_save_db()

# ── Autosave ──────────────────────────────────────────────────────────────────

func save_autosave(state: Dictionary) -> void:
	_data.autosave = state
	_data.autosave["timestamp"] = Time.get_datetime_string_from_system()
	_save_db()

func load_autosave() -> Dictionary:
	return _data.autosave.duplicate()

func clear_autosave() -> void:
	_data.autosave = {}
	_save_db()

func has_autosave() -> bool:
	return _data.autosave.size() > 0

# ── Persistence ───────────────────────────────────────────────────────────────

func _save_db() -> void:
	var file = FileAccess.open(DB_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_data, "\t"))
		file.close()

func _load_db() -> void:
	if not FileAccess.file_exists(DB_PATH):
		return
	var file = FileAccess.open(DB_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if parsed is Dictionary:
			_data = parsed
