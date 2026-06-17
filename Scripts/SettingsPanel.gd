extends Control

@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_btn: Button = %FullscreenBtn
@onready var back_btn: Button = %BackBtn
@onready var volume_label: Label = %VolumeLabel
@onready var fs_label: Label = %FSLabel

var is_fullscreen: bool = false


func _ready() -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	volume_label.text = "Volume: %d%%" % (volume_slider.value * 100)
	volume_slider.drag_ended.connect(func(_v): _on_volume_changed())
	volume_slider.value_changed.connect(func(v): volume_label.text = "Volume: %d%%" % (v * 100))
	fullscreen_btn.pressed.connect(_on_fullscreen_toggled)
	back_btn.pressed.connect(_on_back)


func _on_volume_changed() -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume_slider.value))


func _on_fullscreen_toggled() -> void:
	is_fullscreen = not is_fullscreen
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_btn.text = "ON"
		fs_label.text = "[ON]"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_btn.text = "OFF"
		fs_label.text = "[OFF]"


func _on_back() -> void:
	hide()
