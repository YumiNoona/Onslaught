extends Control

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
	},
	{
		"name": "SIMON",
		"scene": "res://Scenes/Player_Simon.tscn",
		"desc": "Fast glass cannon",
		"ability": "Quick Dash: fast short-dash with invulnerability (2s CD)",
		"pros": "+25% speed, +15% fire rate",
		"cons": "-30% HP",
	},
]

func _ready() -> void:
	for i in 3:
		var c = characters[i]
		var card = get_node("%Card" + str(i))
		card.get_node("NameLabel").text = c["name"]
		card.get_node("DescLabel").text = c["desc"]
		card.get_node("AbilityLabel").text = c["ability"]
		card.get_node("ProsLabel").text = c["pros"]
		card.get_node("ConsLabel").text = c["cons"]
		card.get_node("SelectBtn").pressed.connect(_on_select.bind(c))

func _on_select(c: Dictionary) -> void:
	GameManager.selected_character_scene = c["scene"]
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
