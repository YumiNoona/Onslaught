extends Control

const SETTINGS_PATH = "user://settings.json"

@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_btn: Button = %FullscreenBtn
@onready var back_btn: Button = %BackBtn
@onready var volume_label: Label = %VolumeLabel
@onready var fs_label: Label = %FSLabel

var is_fullscreen: bool = false


func _ready() -> void:
	load_settings()
	volume_slider.drag_ended.connect(func(_v): _on_volume_changed())
	volume_slider.value_changed.connect(func(v): volume_label.text = "Volume: %d%%" % (v * 100))
	fullscreen_btn.pressed.connect(_on_fullscreen_toggled)
	back_btn.pressed.connect(_on_back)


func _on_volume_changed() -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume_slider.value))
	save_settings()


func _on_fullscreen_toggled() -> void:
	is_fullscreen = not is_fullscreen
	apply_fullscreen()
	save_settings()


func apply_fullscreen() -> void:
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_btn.text = "ON"
		fs_label.text = "[ON]"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_btn.text = "OFF"
		fs_label.text = "[OFF]"


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
		apply_fullscreen()
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
		apply_fullscreen()


func _on_back() -> void:
	hide()
