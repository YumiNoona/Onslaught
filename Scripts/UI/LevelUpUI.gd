extends Control

signal closed

const FONT = preload("res://Assets/Fonts/kenpixel_mini_square.ttf")

var perk_pool: Array[Dictionary] = []
var selected_perks: Array[Dictionary] = []

@onready var cards := [%Card0, %Card1, %Card2]
@onready var skip_btn: Button = %SkipBtn

func _ready() -> void:
	skip_btn.pressed.connect(_on_skip)
	perk_pool = [
		{"name": "Move Speed +10%", "apply": func(p): p.move_speed *= 1.1},
		{"name": "+1 Max HP", "apply": func(p): var amount = p.health_on_level_up; p.health_component.max_health += amount; p.health_component.current_health = min(p.health_component.current_health + amount, p.health_component.max_health)},
		{"name": "Bullet Pierce +1", "apply": func(p): p.pierce_bonus += 1, "max": 5},
		{"name": "Fire Rate +20%", "apply": func(p): p.fire_rate_mod += 0.2},
		{"name": "Damage +1", "apply": func(p): p.damage_bonus += 1},
		{"name": "Crit Chance +5%", "apply": func(p): p.crit_bonus += 0.05},
	]

func show_perks() -> void:
	show()

	var pool = perk_pool.duplicate()
	pool = pool.filter(func(perk): return not perk.has("max") or GameManager.player.pierce_bonus < perk["max"])
	pool.shuffle()
	selected_perks = pool.slice(0, min(GameConfig.perk_choice_count, pool.size()))

	populate_cards()

func populate_cards() -> void:
	for i in selected_perks.size():
		var perk = selected_perks[i]
		var card = cards[i]
		card.get_node("PerkLabel").text = perk["name"]
		var btn = card.get_node("SelectBtn") as Button
		btn.disabled = false
		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c["callable"])
		btn.pressed.connect(_on_perk_chosen.bind(perk), CONNECT_ONE_SHOT)

func _on_perk_chosen(perk: Dictionary) -> void:
	perk["apply"].call(GameManager.player)
	GameManager.perks_log.append(perk["name"])
	SoundManager.play_click()
	hide()
	closed.emit()

func _on_skip() -> void:
	SoundManager.play_click()
	hide()
	closed.emit()
