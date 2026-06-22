extends Control

const SETTINGS_PATH = "user://settings.json"

const KEYBIND_ACTIONS = [
	"Move_Up", "Move_Down", "Move_Left", "Move_Right",
	"Shoot", "Dash", "Reload", "Interact",
]

@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_on_btn: Button = %FullscreenOnBtn
@onready var fullscreen_off_btn: Button = %FullscreenOffBtn
@onready var back_btn: Button = %BackBtn
@onready var apply_btn: Button = %ApplyBtn
@onready var volume_label: Label = %VolumeLabel
@onready var vbox: VBoxContainer = %VBox

var is_fullscreen: bool = false
var _rebind_buttons: Dictionary = {}
var _waiting_for_key: String = ""


func _ready() -> void:
	load_settings()
	volume_slider.drag_ended.connect(func(_v): _on_volume_changed())
	volume_slider.value_changed.connect(func(v): volume_label.text = "Volume: %d%%" % (v * 100))
	fullscreen_on_btn.pressed.connect(_on_fullscreen_on)
	fullscreen_off_btn.pressed.connect(_on_fullscreen_off)
	apply_btn.pressed.connect(_on_apply)
	back_btn.pressed.connect(_on_back)
	_build_keybind_ui()


func _build_keybind_ui() -> void:
	# Separator label
	var sep = Label.new()
	sep.text = "--- KEYBINDS ---"
	sep.add_theme_font_override("font", preload("res://Assets/Fonts/kenpixel_mini_square.ttf"))
	sep.add_theme_font_size_override("font_size", 18)
	vbox.add_child(sep)

	for action in KEYBIND_ACTIONS:
		var row = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = _action_display_name(action) + ":"
		lbl.add_theme_font_override("font", preload("res://Assets/Fonts/kenpixel_mini_square.ttf"))
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var btn = Button.new()
		btn.text = _get_key_display(action)
		btn.add_theme_font_override("font", preload("res://Assets/Fonts/kenpixel_mini_square.ttf"))
		btn.add_theme_font_size_override("font_size", 18)
		btn.custom_minimum_size = Vector2(100, 0)
		btn.pressed.connect(_on_rebind_pressed.bind(action, btn))

		row.add_child(lbl)
		row.add_child(btn)
		vbox.add_child(row)
		_rebind_buttons[action] = btn


func _action_display_name(action: String) -> String:
	match action:
		"Move_Up": return "Move Up"
		"Move_Down": return "Move Down"
		"Move_Left": return "Move Left"
		"Move_Right": return "Move Right"
		"Shoot": return "Shoot"
		"Dash": return "Dash"
		"Reload": return "Reload"
		"Interact": return "Ability"
	return action


func _get_key_display(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for e in events:
		if e is InputEventKey:
			return OS.get_keycode_string(e.physical_keycode)
	return "?"


func _on_rebind_pressed(action: String, btn: Button) -> void:
	_waiting_for_key = action
	btn.text = "..."
	btn.modulate = Color(1, 1, 0, 1)
	# Listen for the next key press (5s timeout)
	get_tree().create_timer(5.0, false, false, true).timeout.connect(
		func(): _cancel_rebind(action, btn), CONNECT_ONE_SHOT)


func _input(event: InputEvent) -> void:
	if not visible or _waiting_for_key.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var action = _waiting_for_key
		_waiting_for_key = ""
		var btn = _rebind_buttons.get(action)
		if not btn:
			return

		# Clear old bindings and assign new
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

		btn.text = OS.get_keycode_string(event.physical_keycode)
		btn.modulate = Color(1, 1, 1, 1)
		get_viewport().set_input_as_handled()
		save_settings()


func _cancel_rebind(action: String, btn: Button) -> void:
	if _waiting_for_key == action:
		_waiting_for_key = ""
		btn.text = _get_key_display(action)
		btn.modulate = Color(1, 1, 1, 1)


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


func _save_keybinds() -> Dictionary:
	var binds = {}
	for action in KEYBIND_ACTIONS:
		var events = InputMap.action_get_events(action)
		for e in events:
			if e is InputEventKey:
				binds[action] = e.physical_keycode
				break
	return binds

func _load_keybinds(data: Dictionary) -> void:
	var binds = data.get("keybinds", {})
	for action in KEYBIND_ACTIONS:
		var code = binds.get(action, 0)
		if code == 0:
			continue
		InputMap.action_erase_events(action)
		var ev = InputEventKey.new()
		ev.physical_keycode = code
		InputMap.action_add_event(action, ev)


func save_settings() -> void:
	var f = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({
		"volume": volume_slider.value,
		"fullscreen": is_fullscreen,
		"keybinds": _save_keybinds(),
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
		_load_keybinds(data)


func _on_back() -> void:
	hide()
