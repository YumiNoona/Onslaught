extends Node

@warning_ignore("unused_signal")

signal on_enemy_died

@warning_ignore("unused_signal")

signal on_shake_request(multiplier: float)

@warning_ignore("unused_signal")

signal on_game_over

@warning_ignore("unused_signal")
signal on_combo_broken

@warning_ignore("unused_signal")
signal on_weapon_fired(shoot_direction: Vector2)

@warning_ignore("unused_signal")
signal on_player_hit

@warning_ignore("unused_signal")
signal on_level_up

@warning_ignore("unused_signal")
signal on_powerup_started(type: int, name: String, duration: float, color: Color)

@warning_ignore("unused_signal")
signal on_powerup_ended(type: int)

const EXLPOSION_ANIM = preload("res://Scenes/Exlposion_Anim.tscn")
const COIN = preload("res://Scenes/Coin.tscn")
const HIT_MATERIAL = preload("res://Material/HitMaterial.tres")
const HEAL_MATERIAL = preload("res://Material/HealMaterial.tres")
const DAMAGE_TEXT = preload("res://Scenes/DamageText.tscn")

var player: Player
var selected_character_scene: String = "res://Scenes/Player.tscn"
var coins: int = 500
var is_game_over: bool = false
var highscore: int = 0
var persistent_kills: int = 0
var persistent_max_wave: int = 0
var persistent_max_streak: int = 0

# Score & wave tracking
var score: int = 0
var current_wave: int = 0

# Combo system
var kill_streak: int = 0
var last_kill_time: float = 0.0

# XP & leveling
var xp: int = 0
var level: int = 1
var xp_to_next: int = 100

# Active power-ups for HUD
var active_powerups: Array[Dictionary] = []

# Stats tracking for game over screen
var total_enemies_killed: int = 0
var game_start_time: int = 0

# Difficulty multiplier
var difficulty_multiplier: float = 1.0

# Hit freeze cooldown
var hit_freeze_cooldown: float = 0.0

# Tracked perks for pause display
var perks_log: Array[String] = []

const SAVE_PATH = "user://highscore.json"

var achievement_defs := [
	{"id": "first_kill", "name": "First Blood", "desc": "Kill your first enemy", "icon": null, "unlocked": false},
	{"id": "kills_10", "name": "Scrapper", "desc": "Kill 10 enemies total", "icon": null, "unlocked": false},
	{"id": "kills_100", "name": "Slayer", "desc": "Kill 100 enemies total", "icon": null, "unlocked": false},
	{"id": "kills_500", "name": "Massacre", "desc": "Kill 500 enemies total", "icon": null, "unlocked": false},
	{"id": "wave_5", "name": "Getting Started", "desc": "Reach wave 5", "icon": null, "unlocked": false},
	{"id": "wave_10", "name": "Veteran", "desc": "Reach wave 10", "icon": null, "unlocked": false},
	{"id": "wave_20", "name": "Legend", "desc": "Reach wave 20", "icon": null, "unlocked": false},
	{"id": "highscore_1000", "name": "High Scorer", "desc": "Score 1000 in a single run", "icon": null, "unlocked": false},
	{"id": "highscore_5000", "name": "Elite", "desc": "Score 5000 in a single run", "icon": null, "unlocked": false},
	{"id": "unlock_rocky", "name": "Unstoppable", "desc": "Unlock Rocky (100 kills)", "icon": null, "unlocked": false},
	{"id": "unlock_simon", "name": "Wave Rider", "desc": "Unlock Simon (wave 10)", "icon": null, "unlocked": false},
	{"id": "combo_10", "name": "Combo Master", "desc": "Reach a 10-kill streak", "icon": null, "unlocked": false},
]

func _ready():
	var combo_timer = Timer.new()
	combo_timer.name = "ComboTimer"
	combo_timer.wait_time = GameConfig.combo_timer_timeout
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timeout)
	add_child(combo_timer)
	load_highscore()

func _process(delta: float) -> void:
	if hit_freeze_cooldown > 0:
		hit_freeze_cooldown -= delta

func load_highscore() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(f.get_as_text())
		if data:
			if data.has("highscore"):
				highscore = data["highscore"]
			if data.has("persistent_kills"):
				persistent_kills = data["persistent_kills"]
			if data.has("persistent_max_wave"):
				persistent_max_wave = data["persistent_max_wave"]
			if data.has("persistent_max_streak"):
				persistent_max_streak = data["persistent_max_streak"]
			if data.has("achievements"):
				var unlocked_ids: Array = data["achievements"]
				for a in achievement_defs:
					if a["id"] in unlocked_ids:
						a["unlocked"] = true
		f.close()
	check_achievements()

func save_highscore() -> void:
	if score > highscore:
		highscore = score
	persistent_kills += total_enemies_killed
	if current_wave > persistent_max_wave:
		persistent_max_wave = current_wave
	if kill_streak > persistent_max_streak:
		persistent_max_streak = kill_streak
	check_achievements()
	var unlocked_ids: Array[String] = []
	for a in achievement_defs:
		if a["unlocked"]:
			unlocked_ids.append(a["id"])
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({
		"highscore": highscore,
		"persistent_kills": persistent_kills,
		"persistent_max_wave": persistent_max_wave,
		"persistent_max_streak": persistent_max_streak,
		"achievements": unlocked_ids,
	}))
	f.close()

func check_achievements() -> void:
	for a in achievement_defs:
		if a["unlocked"]:
			continue
		match a["id"]:
			"first_kill":
				a["unlocked"] = persistent_kills >= 1
			"kills_10":
				a["unlocked"] = persistent_kills >= 10
			"kills_100":
				a["unlocked"] = persistent_kills >= 100
			"kills_500":
				a["unlocked"] = persistent_kills >= 500
			"wave_5":
				a["unlocked"] = persistent_max_wave >= 5
			"wave_10":
				a["unlocked"] = persistent_max_wave >= 10
			"wave_20":
				a["unlocked"] = persistent_max_wave >= 20
			"highscore_1000":
				a["unlocked"] = highscore >= 1000
			"highscore_5000":
				a["unlocked"] = highscore >= 5000
			"unlock_rocky":
				a["unlocked"] = persistent_kills >= 100
			"unlock_simon":
				a["unlocked"] = persistent_max_wave >= 10
			"combo_10":
				a["unlocked"] = persistent_max_streak >= 10

func check_highscore() -> bool:
	return score > highscore

func reset_game_state():
	is_game_over = false
	coins = GameConfig.starting_coins
	score = 0
	current_wave = 0
	kill_streak = 0
	last_kill_time = 0.0
	xp = 0
	level = 1
	xp_to_next = GameConfig.base_xp_to_next
	active_powerups.clear()
	total_enemies_killed = 0
	perks_log.clear()
	game_start_time = Time.get_ticks_msec()
	difficulty_multiplier = 1.0
	hit_freeze_cooldown = 0.0
	Engine.time_scale = 1.0
	var ct = get_node_or_null("ComboTimer")
	if ct:
		ct.stop()
	print("Game state reset")

func add_score(amount: int) -> void:
	score += amount

func increment_combo() -> void:
	kill_streak += 1
	last_kill_time = Time.get_ticks_msec() / 1000.0
	var ct = get_node_or_null("ComboTimer")
	if ct:
		ct.stop()
		ct.start()

func _on_combo_timeout() -> void:
	kill_streak = 0
	on_combo_broken.emit()

func play_explosion_anim(pos: Vector2) -> void:
	var anim: AnimatedSprite2D = EXLPOSION_ANIM.instantiate()
	anim.global_position = pos
	anim.z_index = 99
	get_tree().current_scene.add_child(anim)
	await anim.animation_finished
	anim.queue_free()

func play_damage_text(pos: Vector2, value: int, is_crit: bool = false) -> void:
	var damage = DAMAGE_TEXT.instantiate() as DamageText
	get_tree().current_scene.add_child(damage)
	damage.global_position = pos
	damage.setup(value, is_crit)

func create_coin(pos: Vector2) -> void:
	if randf_range(0, 100) <= GameConfig.coin_drop_chance * 100:
		var coin := COIN.instantiate() as Coin
		coin.global_position = pos
		get_tree().current_scene.call_deferred("add_child", coin)

func remove_coin(amount: int) -> void:
	coins -= amount
	if coins <= 0:
		coins = 0

func add_xp(amount: int) -> void:
	xp += amount
	if xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = level * GameConfig.xp_curve_multiplier
		on_level_up.emit()
