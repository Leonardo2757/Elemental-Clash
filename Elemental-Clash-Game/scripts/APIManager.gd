extends Node

signal api_data_ready(data: Dictionary)
signal api_failed()
signal post_done(success: bool)

const MAX_RETRIES   = 3
const RETRY_DELAY   = 2.0

# Fallback weather data used when API is unreachable
const FALLBACK_DATA = {
	"temperature":  22.0,
	"weathercode":  0,
	"description":  "Soleado (datos locales)",
	"bonus_element": "FIRE",
	"bonus_dmg":    2
}

var _retry_count  : int  = 0
var _weather_data : Dictionary = FALLBACK_DATA.duplicate()
var _http          : HTTPRequest

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_weather_response)
	fetch_weather()

func fetch_weather() -> void:
	_retry_count = 0
	_do_request()

func _do_request() -> void:
	# Open-Meteo: free, no key, CORS-safe for web exports
	var url = ConfigManager.api_base_url + \
		"/forecast?latitude=20.68&longitude=-103.35&current_weather=true"
	var err = _http.request(url)
	if err != OK:
		_schedule_retry()

func _on_weather_response(result: int, _code: int, _headers: PackedStringArray,
		body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_schedule_retry()
		return

	var txt  = body.get_string_from_utf8()
	var json = JSON.parse_string(txt)
	if json == null or not json.has("current_weather"):
		_schedule_retry()
		return

	var cw    = json["current_weather"]
	var temp  = float(cw.get("temperature", 20))
	var wcode = int(cw.get("weathercode", 0))
	_weather_data = {
		"temperature":  temp,
		"weathercode":  wcode,
		"description":  _describe(wcode),
		"bonus_element": _bonus_element(temp, wcode),
		"bonus_dmg":    _bonus_dmg(temp, wcode)
	}
	_retry_count = 0
	api_data_ready.emit(_weather_data)

func _schedule_retry() -> void:
	_retry_count += 1
	if _retry_count >= MAX_RETRIES:
		push_warning("APIManager: max retries reached, using fallback")
		_weather_data = FALLBACK_DATA.duplicate()
		api_failed.emit()
		return
	await get_tree().create_timer(RETRY_DELAY).timeout
	_do_request()

func get_weather() -> Dictionary:
	return _weather_data.duplicate()

# ── POST results ──────────────────────────────────────────────────────────────

func post_session_result(session: Dictionary) -> void:
	var post_http = HTTPRequest.new()
	add_child(post_http)
	post_http.request_completed.connect(
		func(_r, code, _h, _b):
			post_done.emit(code == 200 or code == 201 or code == 200)
			post_http.queue_free()
	)
	var body    = JSON.stringify(session)
	var headers = ["Content-Type: application/json"]
	var err     = post_http.request(ConfigManager.post_api_url,
		headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		post_done.emit(false)
		post_http.queue_free()

# ── Helpers ───────────────────────────────────────────────────────────────────

func _describe(code: int) -> String:
	if code == 0:            return "Despejado"
	elif code <= 3:          return "Parcialmente nublado"
	elif code <= 49:         return "Neblina"
	elif code <= 69:         return "Lluvia"
	elif code <= 79:         return "Nieve"
	elif code <= 99:         return "Tormenta electrica"
	return "Desconocido"

func _bonus_element(temp: float, code: int) -> String:
	if code >= 80:           return "LIGHTNING"
	elif code >= 50:         return "WATER"
	elif temp > 30.0:        return "FIRE"
	elif temp < 10.0:        return "EARTH"
	return "FIRE"

func _bonus_dmg(temp: float, code: int) -> int:
	if code >= 80:           return 3
	elif code >= 50:         return 2
	elif temp > 35.0:        return 3
	return 2
