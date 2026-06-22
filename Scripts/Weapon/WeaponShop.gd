extends Control

signal skipped

const FONT = preload("res://Assets/Fonts/kenpixel_mini_square.ttf")
var all_weapons: Array[WeaponData] = []
var selected_weapons: Array[WeaponData] = []
var bought_any: bool = false
var shop_wave: int = 0

@onready var cards := [%Card0, %Card1, %Card2]
@onready var coins_label: Label = %CoinsLabel
@onready var timer_label: Label = %TimerLabel
@onready var skip_btn: Button = %SkipBtn

func _ready() -> void:
	skip_btn.pressed.connect(_on_skip)
	load_all_weapons()

func load_all_weapons() -> void:
	all_weapons.clear()
	var weapons = [
		preload("res://Data/W_AKM.tres"),
		preload("res://Data/W_AR.tres"),
		preload("res://Data/W_Auto_Pistol.tres"),
		preload("res://Data/W_DoubleShotGun.tres"),
		preload("res://Data/W_HandGun.tres"),
		preload("res://Data/W_M24.tres"),
		preload("res://Data/W_M4.tres"),
		preload("res://Data/W_M416.tres"),
		preload("res://Data/W_Pistol.tres"),
		preload("res://Data/W_ShotGun.tres"),
		preload("res://Data/W_UZI.tres"),
	]
	for w in weapons:
		if w:
			all_weapons.append(w)

var seen_weapons: Array[String] = []

func _process(_delta: float) -> void:
	if not visible:
		return
	var game = get_tree().current_scene
	if game and game.has_node("WaveTimer"):
		var wave_timer = game.get_node("WaveTimer") as Timer
		if not wave_timer.is_stopped():
			timer_label.text = "Wave %s starts in %s" % [shop_wave + 1, int(wave_timer.time_left)]
			timer_label.show()
		else:
			timer_label.hide()
			
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
		
	var unseen = pool.filter(func(w): return w.gun_name not in seen_weapons)
	var seen = pool.filter(func(w): return w.gun_name in seen_weapons)
	
	unseen.shuffle()
	seen.shuffle()
	
	pool = unseen + seen
	selected_weapons = pool.slice(0, 3)
	
	for w in selected_weapons:
		if w.gun_name not in seen_weapons:
			seen_weapons.append(w.gun_name)

	populate_cards()

func populate_cards() -> void:
	if selected_weapons.size() < 3:
		return
	for i in 3:
		var w = selected_weapons[i]
		var card = cards[i]
		card.get_node("NameLabel").text = w.gun_name
		card.get_node("Sprite").texture = w.gun_sprite
		card.get_node("Sprite").modulate = w.gun_colour
		var ammo_str = "∞" if w.max_ammo <= 0 else str(w.max_ammo)
		card.get_node("StatsLabel").text = "DMG: %s  RoF: %s/s\nPierce: %s  Ammo: %s\n%s" % [
			w.damage,
			str(1.0 / w.delay_between_shots).pad_decimals(1),
			w.pierce,
			ammo_str,
			w.description
		]
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
	give_default_if_no_weapon()
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	skipped.emit()

func give_default_if_no_weapon() -> void:
	if GameManager.player.weapon.equipped_weapon == null:
		var cheapest = get_cheapest_weapon()
		if cheapest:
			GameManager.player.setup_weapon(cheapest)

func _on_skip() -> void:
	SoundManager.play_click()
	close_shop()

func get_cheapest_weapon() -> WeaponData:
	var best: WeaponData = null
	for w in all_weapons:
		if best == null or w.buy_price < best.buy_price:
			best = w
	return best
