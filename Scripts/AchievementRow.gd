extends MarginContainer

var desc_text: String

func setup(data: Dictionary) -> void:
	var icon_rect = $VBox/IconRect as TextureRect
	var name_lbl = $VBox/NameLabel as Label
	if data["icon"] and ResourceLoader.exists(data["icon"]):
		icon_rect.texture = load(data["icon"])
		icon_rect.visible = true
	else:
		icon_rect.visible = false
	name_lbl.text = data["name"]
	desc_text = data["desc"]
	tooltip_text = data["desc"]
	if data["unlocked"]:
		icon_rect.modulate = Color(1, 1, 1, 1)
		name_lbl.modulate = Color(1, 1, 1, 1)
		modulate = Color(1, 1, 1, 1)
	else:
		icon_rect.modulate = Color(0.3, 0.3, 0.3, 0.4)
		name_lbl.modulate = Color(0.5, 0.5, 0.5, 0.5)
		modulate = Color(1, 1, 1, 0.5)

func _make_custom_tooltip(for_text: String) -> Object:
	var lbl = Label.new()
	lbl.text = "%s\n%s" % [$VBox/NameLabel.text, desc_text]
	lbl.add_theme_font_override("font", load("res://Assets/Fonts/kenpixel_mini_square.ttf"))
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.modulate = Color(1, 1, 0.8, 1)
	return lbl
