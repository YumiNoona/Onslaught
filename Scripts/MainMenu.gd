extends Control

@onready var btn_start: Button = $BTN_Start
@onready var btn_quit: Button = $BTN_Quit
@onready var btn_settings: Button = $BTN_Settings
@onready var btn_achievements: Button = $BTN_Achievements
@onready var settings_panel: Control = $SettingsPanel
@onready var achievements_panel: Control = $AchievementsPanel
@onready var version_label: Label = $VersionLabel
@onready var deco: TextureRect = $Deco


func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_achievements.pressed.connect(_on_achievements_pressed)
	var t = create_tween().set_loops()
	t.tween_property($Title, "modulate", Color(0.9, 0.9, 1, 0.7), 1.5)
	t.tween_property($Title, "modulate", Color(0.9, 0.9, 1, 1), 1.5)
	version_label.text = "v1.0"


func _process(delta: float) -> void:
	deco.rotation += delta * 0.15


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	settings_panel.show()


func _on_achievements_pressed() -> void:
	achievements_panel.populate()
	achievements_panel.show()
