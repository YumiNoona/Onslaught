extends Control

const SETTINGS_PATH = "user://settings.json"

@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_on_btn: Button = %FullscreenOnBtn
@onready var fullscreen_off_btn: Button = %FullscreenOffBtn
@onready var back_btn: Button = %BackBtn
@onready var apply_btn: Button = %ApplyBtn
@onready var volume_label: Label = %VolumeLabel

var is_fullscreen: bool = false


func _ready() -> void:
	load_settings()
	volume_slider.drag_ended.connect(func(_v): _on_volume_changed())
	volume_slider.value_changed.connect(func(v): volume_label.text = "Volume: %d%%" % (v * 100))
	fullscreen_on_btn.pressed.connect(_on_fullscreen_on)
	fullscreen_off_btn.pressed.connect(_on_fullscreen_off)
	apply_btn.pressed.connect(_on_apply)
	back_btn.pressed.connect(_on_back)


func _on_volume_changed() -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume_slider.value))


func _on_fullscreen_on() -> void:
	is_fullscreen = true
	update_fullscreen_ui()


func _on_fullscreen_off() -> void:
	is_fullscreen = false
	update_fullscreen_ui()


func update_fullscreen_ui() -> void:
	fullscreen_on_btn.modulate = Color(1, 1, 1, 1) if is_fullscreen else Color(0.4, 0.4, 0.4, 1)
	fullscreen_off_btn.modulate = Color(1, 1, 1, 1) if not is_fullscreen else Color(0.4, 0.4, 0.4, 1)


func _on_apply() -> void:
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_slider.value))
	save_settings()


func save_settings() -> void:
	var f = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({
		"volume": volume_slider.value,
		"fullscreen": is_fullscreen,
	}))
	f.close()


func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		volume_slider.value = 1.0
		volume_label.text = "Volume: 100%"
		is_fullscreen = false
		update_fullscreen_ui()
		return
	var f = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if data:
		var vol = data.get("volume", 1.0)
		is_fullscreen = data.get("fullscreen", false)
		volume_slider.value = vol
		volume_label.text = "Volume: %d%%" % (vol * 100)
		var bus_idx = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(vol))
		update_fullscreen_ui()


func _on_back() -> void:
	hide()
