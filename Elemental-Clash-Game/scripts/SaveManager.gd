extends Node

signal autosave_done()

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = ConfigManager.autosave_interval
	_timer.timeout.connect(_on_autosave)
	add_child(_timer)

func start_autosave() -> void:
	_timer.start()

func stop_autosave() -> void:
	_timer.stop()

func save_now() -> void:
	_on_autosave()

func _on_autosave() -> void:
	if GameManager.state == GameManager.GameState.SELECTING or \
	   GameManager.state == GameManager.GameState.REVEALING:
		var snap = GameManager.get_state_snapshot()
		DatabaseManager.save_autosave(snap)
		autosave_done.emit()

func restore_session(snapshot: Dictionary) -> void:
	GameManager.restore_from_snapshot(snapshot)
