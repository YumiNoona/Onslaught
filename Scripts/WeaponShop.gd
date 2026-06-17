extends Control

signal skipped

const FONT = preload("res://Assets/Fonts/kenpixel_mini_square.ttf")
var all_weapons: Array[WeaponData] = []
var selected_weapons: Array[WeaponData] = []
var bought_any: bool = false
var shop_wave: int = 0

@onready var cards := [%Card0, %Card1, %Card2]
@onready var coins_label: Label = %CoinsLabel
@onready var skip_btn: Button = %SkipBtn

func _ready() -> void:
	skip_btn.pressed.connect(_on_skip)
	load_all_weapons()

func load_all_weapons() -> void:
	all_weapons.clear()
	var dir = DirAccess.open("res://Data")
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tres"):
				var w = load("res://Data/" + file) as WeaponData
				if w:
					all_weapons.append(w)

func show_shop() -> void:
	show()
	Input.flush_buffered_events()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	bought_any = false
	shop_wave = GameManager.current_wave

	var pool = all_weapons.duplicate()
	var current = GameManager.player.weapon.equipped_weapon
	if current:
		pool = pool.filter(func(w): return w.gun_name != current.gun_name)
	pool.shuffle()
	selected_weapons = pool.slice(0, 3)

	populate_cards()

func populate_cards() -> void:
	for i in 3:
		var w = selected_weapons[i]
		var card = cards[i]
		card.get_node("NameLabel").text = w.gun_name
		card.get_node("Sprite").texture = w.gun_sprite
		card.get_node("Sprite").modulate = w.gun_colour
		card.get_node("StatsLabel").text = "DMG: %s  RoF: %s/s\nPierce: %s\n%s" % [w.damage, str(1.0 / w.delay_between_shots).pad_decimals(1), w.pierce, w.description]
		card.get_node("PriceLabel").text = "%s coins" % w.buy_price
		var btn = card.get_node("BuyBtn") as Button
		btn.text = "Buy"
		btn.disabled = false
		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c["callable"])
		btn.pressed.connect(_on_buy.bind(w, btn))

	coins_label.text = "Coins: %s" % GameManager.coins

func _on_buy(w: WeaponData, btn: Button) -> void:
	if GameManager.coins < w.buy_price:
		var original = btn.modulate
		btn.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(0.15).timeout
		if is_instance_valid(btn):
			btn.modulate = original
		return
	GameManager.remove_coin(w.buy_price)
	GameManager.player.setup_weapon(w)
	bought_any = true
	SoundManager.play_click()
	close_shop()

func close_shop() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	skipped.emit()

func _on_skip() -> void:
	SoundManager.play_click()
	if not bought_any and shop_wave == 1:
		var cheapest = get_cheapest_weapon()
		if cheapest:
			GameManager.player.setup_weapon(cheapest)
	close_shop()

func get_cheapest_weapon() -> WeaponData:
	var best: WeaponData = null
	for w in all_weapons:
		if best == null or w.buy_price < best.buy_price:
			best = w
	return best
