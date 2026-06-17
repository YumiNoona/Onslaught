extends Control

var game_scene: PackedScene
var game_loaded := false

var characters := [
	{
		"name": "SHOOTER",
		"scene": "res://Scenes/Player.tscn",
		"desc": "Balanced all-rounder",
		"ability": "Adrenaline Rush: +20% speed & fire rate for 3s (10s CD)",
		"pros": "No weaknesses",
		"cons": "No strengths",
	},
	{
		"name": "ROCKY",
		"scene": "res://Scenes/Player_Rocky.tscn",
		"desc": "Heavy-hitting tank",
		"ability": "Ground Slam: knocks back & damages nearby enemies (6s CD)",
		"pros": "+50% HP, damage resist",
		"cons": "-20% move speed, -15% fire rate",
		"unlock_hint": "Kill 100 enemies total",
		"unlock_check": func(): return GameManager.persistent_kills >= 100,
	},
	{
		"name": "SIMON",
		"scene": "res://Scenes/Player_Simon.tscn",
		"desc": "Fast glass cannon",
		"ability": "Quick Dash: fast short-dash with invulnerability (2s CD)",
		"pros": "+25% speed, +15% fire rate",
		"cons": "-30% HP",
		"unlock_hint": "Reach wave 10",
		"unlock_check": func(): return GameManager.persistent_max_wave >= 10,
	},
]

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://Scenes/Game.tscn")
	var title = $VBox/Title
	var t = create_tween().set_loops()
	t.tween_property(title, "modulate", Color(0.9, 0.9, 1, 0.7), 1.5)
	t.tween_property(title, "modulate", Color(0.9, 0.9, 1, 1), 1.5)
	for i in 3:
		var c = characters[i]
		var card = get_node("%Card" + str(i))
		card.get_node("NameLabel").text = c["name"]
		card.get_node("DescLabel").text = c["desc"]
		card.get_node("AbilityLabel").text = c["ability"]
		card.get_node("ProsLabel").text = c["pros"]
		card.get_node("ConsLabel").text = c["cons"]
		var btn = card.get_node("SelectBtn") as Button
		if c.has("unlock_check") and not c["unlock_check"].call():
			btn.text = "LOCKED"
			btn.disabled = true
			card.get_node("DescLabel").text = "LOCKED — %s" % c["unlock_hint"]
		else:
			btn.text = "SELECT"
			btn.pressed.connect(_on_select.bind(c))
	$VBox/DiffRow/BtnEasy.pressed.connect(_set_diff.bind(GameConfig.difficulty_easy_mult, "BtnEasy"))
	$VBox/DiffRow/BtnNormal.pressed.connect(_set_diff.bind(GameConfig.difficulty_normal_mult, "BtnNormal"))
	$VBox/DiffRow/BtnHard.pressed.connect(_set_diff.bind(GameConfig.difficulty_hard_mult, "BtnHard"))

func _set_diff(mult: float, btn: String) -> void:
	GameManager.difficulty_multiplier = mult
	var selected = Color(0.3, 0.7, 0.3, 1)
	var normal = Color(0.5, 0.5, 0.5, 1)
	for b in ["BtnEasy", "BtnNormal", "BtnHard"]:
		var node = $VBox/DiffRow.get_node(b)
		node.modulate = selected if b == btn else normal

func _process(_delta: float) -> void:
	if not game_loaded and ResourceLoader.load_threaded_get_status("res://Scenes/Game.tscn") == ResourceLoader.THREAD_LOAD_LOADED:
		game_scene = ResourceLoader.load_threaded_get("res://Scenes/Game.tscn") as PackedScene
		game_loaded = true

func _on_select(c: Dictionary) -> void:
	GameManager.selected_character_scene = c["scene"]
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
