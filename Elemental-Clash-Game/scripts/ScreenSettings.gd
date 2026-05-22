extends Control

@onready var _slider_music  : HSlider  = $VBox/SliderMusic
@onready var _slider_sfx    : HSlider  = $VBox/SliderSFX
@onready var _edit_api_base : LineEdit = $VBox/EditAPIBase
@onready var _edit_api_post : LineEdit = $VBox/EditAPIPost
@onready var _edit_autosave : LineEdit = $VBox/EditAutosave
@onready var _btn_save      : Button   = $VBox/BtnSave
@onready var _btn_back      : Button   = $VBox/BtnBack
@onready var _lbl_saved     : Label    = $VBox/LblSaved

func _ready() -> void:
	_btn_save.pressed.connect(_on_save)
	_btn_back.pressed.connect(_on_back)
	_lbl_saved.visible = false
	GameManager.state_changed.connect(_on_state_changed)
	

func _on_state_changed(s: GameManager.GameState) -> void:
	if s == GameManager.GameState.SETTINGS:
		_slider_music.value    = ConfigManager.music_volume
		_slider_sfx.value      = ConfigManager.sfx_volume
		_edit_api_base.text    = ConfigManager.api_base_url
		_edit_api_post.text    = ConfigManager.post_api_url
		_edit_autosave.text    = str(ConfigManager.autosave_interval)

func _on_save() -> void:
	ConfigManager.set_music_volume(_slider_music.value)
	ConfigManager.set_sfx_volume(_slider_sfx.value)
	ConfigManager.api_base_url     = _edit_api_base.text.strip_edges()
	ConfigManager.post_api_url     = _edit_api_post.text.strip_edges()
	ConfigManager.autosave_interval = float(_edit_autosave.text) if _edit_autosave.text.is_valid_float() else 30.0
	ConfigManager.save_settings()
	AudioManager.play_sfx_confirm()
	_lbl_saved.visible = true
	_lbl_saved.text    = "Configuracion guardada."
	await get_tree().create_timer(2.0).timeout
	_lbl_saved.visible = false

func _on_back() -> void:
	get_parent().get_parent().back_to_menu()
