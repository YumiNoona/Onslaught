extends Control

@onready var btn_start: Button = $BTN_Start
@onready var btn_quit: Button = $BTN_Quit
@onready var title: Label = $Title

func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	var t = create_tween().set_loops()
	t.tween_property(title, "modulate", Color(0.9, 0.9, 1, 0.7), 1.5)
	t.tween_property(title, "modulate", Color(0.9, 0.9, 1, 1), 1.5)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
