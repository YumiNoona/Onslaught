extends Control

const FONT = preload("res://Assets/Fonts/kenpixel_mini_square.ttf")

var all_weapons: Array[WeaponData] = []

func show_shop() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	for child in get_children():
		child.queue_free()
	await get_tree().process_frame

	all_weapons.clear()
	var dir = DirAccess.open("res://Data")
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tres"):
				var w = load("res://Data/" + file) as WeaponData
				if w:
					all_weapons.append(w)

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg)

	var margin = MarginContainer.new()
	margin.anchors_preset = Control.PRESET_FULL_RECT
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.anchors_preset = Control.PRESET_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	var header = Label.new()
	header.text = "WEAPON SHOP"
	header.add_theme_font_override("font", FONT)
	header.add_theme_font_size_override("font_size", 60)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	var coins_label = Label.new()
	coins_label.text = "Coins: %s" % GameManager.coins
	coins_label.add_theme_font_override("font", FONT)
	coins_label.add_theme_font_size_override("font_size", 30)
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(coins_label)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)
	vbox.add_child(hbox)

	var selected = all_weapons.duplicate()
	selected.shuffle()
	selected = selected.slice(0, 3)

	for w in selected:
		var card = VBoxContainer.new()
		card.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_theme_constant_override("separation", 8)
		card.custom_minimum_size = Vector2(220, 240)
		hbox.add_child(card)

		var name_label = Label.new()
		name_label.text = w.gun_name
		name_label.add_theme_font_override("font", FONT)
		name_label.add_theme_font_size_override("font_size", 22)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(name_label)

		var sprite = TextureRect.new()
		sprite.texture = w.gun_sprite
		sprite.modulate = w.gun_colour
		sprite.custom_minimum_size = Vector2(150, 50)
		sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		card.add_child(sprite)

		var stats_label = Label.new()
		stats_label.text = "DMG: %s  Rate: %s/s\nPierce: %s" % [w.damage, str(1.0 / w.delay_between_shots).pad_decimals(1), w.pierce]
		stats_label.add_theme_font_override("font", FONT)
		stats_label.add_theme_font_size_override("font_size", 16)
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(stats_label)

		var price_label = Label.new()
		price_label.text = "%s coins" % w.buy_price
		price_label.add_theme_font_override("font", FONT)
		price_label.add_theme_font_size_override("font_size", 20)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(price_label)

		var btn = Button.new()
		btn.text = "Buy"
		btn.custom_minimum_size = Vector2(200, 45)
		btn.pressed.connect(_on_buy.bind(w, btn, coins_label))
		card.add_child(btn)

	var skip_btn = Button.new()
	skip_btn.text = "Skip (Next Wave)"
	skip_btn.custom_minimum_size = Vector2(300, 50)
	skip_btn.pressed.connect(_on_skip)
	vbox.add_child(skip_btn)

func _on_buy(w: WeaponData, btn: Button, coins_label: Label) -> void:
	if GameManager.coins < w.buy_price:
		return
	GameManager.remove_coin(w.buy_price)
	GameManager.player.setup_weapon(w)
	btn.disabled = true
	btn.text = "Owned"
	coins_label.text = "Coins: %s" % GameManager.coins

func _on_skip() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
