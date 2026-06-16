extends Control

const FONT = preload("res://Assets/Fonts/kenpixel_mini_square.ttf")

var perk_pool: Array[Dictionary] = []
var selected_perks: Array[Dictionary] = []

@onready var cards := [%Card0, %Card1, %Card2]
@onready var skip_btn: Button = %SkipBtn

func _ready() -> void:
	skip_btn.pressed.connect(_on_skip)

func show_perks() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()

	perk_pool = [
		{"name": "Move Speed +10%", "apply": func(p): p.move_speed *= 1.1},
		{"name": "+1 Max HP", "apply": func(p): var amount = p.health_on_level_up; p.health_component.max_health += amount; p.health_component.current_health = min(p.health_component.current_health + amount, p.health_component.max_health)},
		{"name": "Bullet Pierce +1", "apply": func(p): p.pierce_bonus += 1},
		{"name": "Fire Rate +20%", "apply": func(p): p.fire_rate_mod += 0.2},
		{"name": "Damage +1", "apply": func(p): p.damage_bonus += 1},
	]

	var pool = perk_pool.duplicate()
	pool.shuffle()
	selected_perks = pool.slice(0, 3)

	populate_cards()

func populate_cards() -> void:
	for i in 3:
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
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_skip() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
