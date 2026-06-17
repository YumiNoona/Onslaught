extends Control

var parent_width: float = 0.0


func setup(data: Dictionary, container_width: float = 0.0) -> void:
	parent_width = container_width
	custom_minimum_size = Vector2(350, 50)
	size = Vector2(350, 50)
	modulate = Color(1, 1, 1, 0)
	position = Vector2(container_width, 10)

	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = 3
	add_child(hbox)

	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(32, 32)
	icon_rect.size = Vector2(32, 32)
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if data.get("icon") and ResourceLoader.exists(data["icon"]):
		icon_rect.texture = load(data["icon"])
	else:
		var fallback = ColorRect.new()
		fallback.custom_minimum_size = Vector2(32, 32)
		fallback.size = Vector2(32, 32)
		fallback.color = Color(1, 0.85, 0, 1)
		icon_rect.add_child(fallback)
	hbox.add_child(icon_rect)

	var name_lbl = Label.new()
	name_lbl.text = data.get("name", "Achievement Unlocked!")
	name_lbl.add_theme_font_override("font", load("res://Assets/Fonts/kenpixel_mini_square.ttf"))
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(name_lbl)

	var target_x = container_width - size.x - 10
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(target_x, 10), 0.3).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.tween_interval(2.5)
	tween.tween_property(self, "position", Vector2(container_width, 10), 0.3)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(queue_free)
