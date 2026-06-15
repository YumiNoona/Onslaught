extends Control

const FONT = preload("res://Assets/Fonts/kenpixel_mini_square.ttf")

var perk_pool: Array[Dictionary] = []

func show_perks() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()

	for child in get_children():
		child.queue_free()
	await get_tree().process_frame

	perk_pool = [
		{"name": "Move Speed +10%", "apply": func(p): p.move_speed *= 1.1},
		{"name": "+1 Max HP", "apply": func(p): var amount = p.health_on_level_up; p.health_component.max_health += amount; p.health_component.current_health = min(p.health_component.current_health + amount, p.health_component.max_health)},
		{"name": "Bullet Pierce +1", "apply": func(p): p.pierce_bonus += 1},
		{"name": "Fire Rate +20%", "apply": func(p): p.fire_rate_mod += 0.2},
		{"name": "Damage +1", "apply": func(p): p.damage_bonus += 1},
	]

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg)

	var margin = MarginContainer.new()
	margin.anchors_preset = Control.PRESET_FULL_RECT
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.anchors_preset = Control.PRESET_CENTER
	vbox.add_theme_constant_override("separation", 30)
	margin.add_child(vbox)

	var header = Label.new()
	header.text = "LEVEL UP!"
	header.add_theme_font_override("font", FONT)
	header.add_theme_font_size_override("font_size", 70)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 40)
	vbox.add_child(hbox)

	var selected = perk_pool.duplicate()
	selected.shuffle()
	selected = selected.slice(0, 3)

	for perk in selected:
		var card = VBoxContainer.new()
		card.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_theme_constant_override("separation", 15)
		card.custom_minimum_size = Vector2(240, 160)
		hbox.add_child(card)

		var name_label = Label.new()
		name_label.text = perk["name"]
		name_label.add_theme_font_override("font", FONT)
		name_label.add_theme_font_size_override("font_size", 22)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(name_label)

		var btn = Button.new()
		btn.text = "Select"
		btn.custom_minimum_size = Vector2(160, 40)
		btn.pressed.connect(_on_perk_chosen.bind(perk))
		card.add_child(btn)

func _on_perk_chosen(perk: Dictionary) -> void:
	perk["apply"].call(GameManager.player)
	for child in find_children("*", "Button", true, false):
		child.disabled = true
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
