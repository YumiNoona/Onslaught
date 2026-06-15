extends Control

@onready var btn_start: Button = $BTN_Start
@onready var btn_quit: Button = $BTN_Quit

func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
