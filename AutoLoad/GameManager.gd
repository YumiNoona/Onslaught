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

const SAVE_PATH = "user://highscore.json"

func _ready():
	var combo_timer = Timer.new()
	combo_timer.name = "ComboTimer"
	combo_timer.wait_time = 2.0
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timeout)
	add_child(combo_timer)
	load_highscore()

func load_highscore() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(f.get_as_text())
		if data and data.has("highscore"):
			highscore = data["highscore"]
		f.close()

func save_highscore() -> void:
	if score <= highscore:
		return
	highscore = score
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"highscore": highscore}))
	f.close()

func check_highscore() -> bool:
	return score > highscore

func reset_game_state():
	is_game_over = false
	coins = 200
	score = 0
	current_wave = 0
	kill_streak = 0
	last_kill_time = 0.0
	xp = 0
	level = 1
	xp_to_next = 100
	active_powerups.clear()
	total_enemies_killed = 0
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

func play_damage_text(pos: Vector2, value: int) -> void:
	var damage = DAMAGE_TEXT.instantiate() as DamageText
	get_tree().current_scene.add_child(damage)
	damage.global_position = pos
	damage.setup(value)

func create_coin(pos: Vector2) -> void:
	if randf_range(0, 100) <= 50:
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
		xp_to_next = level * 80
		on_level_up.emit()
