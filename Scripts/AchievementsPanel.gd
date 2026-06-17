extends Control

@onready var container: VBoxContainer = %AchievementList
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	back_btn.pressed.connect(func(): hide())


func populate() -> void:
	for c in container.get_children():
		c.queue_free()
	for a in GameManager.achievement_defs:
		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 50)
		row.size_flags_horizontal = 3
		row.size_flags_vertical = 0

		var icon = ColorRect.new()
		icon.custom_minimum_size = Vector2(32, 32)
		icon.size = Vector2(32, 32)
		icon.color = Color(1, 0.85, 0, 1) if a["unlocked"] else Color(0.3, 0.3, 0.3, 1)
		row.add_child(icon)

		var text_vbox = VBoxContainer.new()
		text_vbox.size_flags_horizontal = 3

		var name_lbl = Label.new()
		name_lbl.text = a["name"]
		name_lbl.theme_override_fonts/font = load("res://Assets/Fonts/kenpixel_mini_square.ttf")
		name_lbl.theme_override_font_sizes/font_size = 20
		name_lbl.modulate = Color(1, 1, 1, 1) if a["unlocked"] else Color(0.5, 0.5, 0.5, 1)
		text_vbox.add_child(name_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = a["desc"]
		desc_lbl.theme_override_fonts/font = load("res://Assets/Fonts/kenpixel_mini_square.ttf")
		desc_lbl.theme_override_font_sizes/font_size = 14
		desc_lbl.modulate = Color(0.7, 0.7, 0.7, 1)
		text_vbox.add_child(desc_lbl)

		row.add_child(text_vbox)

		var status_lbl = Label.new()
		status_lbl.text = "✓" if a["unlocked"] else "✗"
		status_lbl.theme_override_fonts/font = load("res://Assets/Fonts/kenpixel_mini_square.ttf")
		status_lbl.theme_override_font_sizes/font_size = 22
		status_lbl.modulate = Color(0, 1, 0, 1) if a["unlocked"] else Color(0.5, 0.1, 0.1, 1)
		row.add_child(status_lbl)

		container.add_child(row)
