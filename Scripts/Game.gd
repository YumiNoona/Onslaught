extends Node2D
class_name Game

var player: Player
@onready var crosshair: Sprite2D = $CrossHair
@onready var camera_2d: Camera2D = $Camera2D
@onready var weapons: Node2D = $Weapons
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var wave_label: Label = %WaveLabel
@onready var enemy_count_label: Label = %EnemyCountLabel
@onready var coins_label: Label = %CoinsLabel
@onready var score_label: Label = %ScoreLabel
@onready var combo_label: Label = %ComboLabel
@onready var wave_announce: Label = %WaveAnnounceLabel
@onready var wave_timer: Timer = $WaveTimer
@onready var xp_bar: ProgressBar = %XpBar
@onready var powerup_indicator: VBoxContainer = %PowerUpIndicator
@onready var ability_bar: ProgressBar = %AbilityBar
@onready var reload_bar: ProgressBar = %ReloadBar
@onready var ammo_label: Label = %AmmoLabel
@onready var boss_health_bar: ProgressBar = %BossHealthBar
@onready var boss_health_label: Label = %BossHealthLabel

@onready var stats_speed: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsSpeed
@onready var stats_damage: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsDamage
@onready var stats_pierce: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsPierce
@onready var stats_fire_rate: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsFireRate
@onready var stats_level: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsLevel
@onready var stats_xp: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsXp
@onready var stats_perks: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsPerks
@onready var hit_flash: ColorRect = $CanvasLayer/HitFlash
@onready var level_up_ui: Control = $CanvasLayer/LevelUpUI
@onready var weapon_shop: Control = $CanvasLayer/WeaponShop
@onready var fade_overlay: ColorRect = $CanvasLayer/FadeOverlay
@onready var vignette: ColorRect = $CanvasLayer/ColorRect

# Game Over UI
@onready var game_over_ui: Control = $CanvasLayer/GameOverUI
@onready var gameover_btn_restart: Button = $CanvasLayer/GameOverUI/VBoxContainer/BTN_Restart
@onready var gameover_btn_quit: Button = $CanvasLayer/GameOverUI/VBoxContainer/BTN_Quit
@onready var gameover_score: Label = $CanvasLayer/GameOverUI/VBoxContainer/ScoreDisplay
@onready var gameover_new_best: Label = $CanvasLayer/GameOverUI/VBoxContainer/NewBestLabel
@onready var gameover_wave: Label = $CanvasLayer/GameOverUI/VBoxContainer/WaveReached
@onready var gameover_kills: Label = $CanvasLayer/GameOverUI/VBoxContainer/EnemiesKilled
@onready var gameover_coins: Label = $CanvasLayer/GameOverUI/VBoxContainer/CoinsCollected
@onready var gameover_highscore: Label = $CanvasLayer/GameOverUI/VBoxContainer/HighScoreLabel

# Pause Menu UI
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var pause_btn_resume: Button = $CanvasLayer/PauseMenu/VBoxContainer/BTN_Resume
@onready var pause_btn_restart: Button = $CanvasLayer/PauseMenu/VBoxContainer/BTN_Restart
@onready var pause_btn_main_menu: Button = $CanvasLayer/PauseMenu/VBoxContainer/BTN_MainMenu

# Preload main menu for faster transition
var main_menu_scene := preload("res://Scenes/MainMenu.tscn")

const POWERUP_LABEL = preload("res://Scenes/PowerUpLabel.tscn")

var combo_tween: Tween
var crosshair_recoil: Vector2 = Vector2.ZERO
var tracked_boss: Enemy = null
var health_pulse_time: float = 0.0
var hud_update_counter: int = 0


func _ready() -> void:
	GameManager.reset_game_state()
	var scene = load(GameManager.selected_character_scene) as PackedScene
	player = scene.instantiate()
	player.name = "Player Veneca"
	add_child(player)
	move_child(player, 0)
	GameManager.player = player
	wave_timer.start()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GameManager.on_game_over.connect(_on_game_over)

	# Game Over UI setup
	game_over_ui.visible = false
	game_over_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	gameover_btn_restart.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	gameover_btn_quit.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	gameover_btn_restart.pressed.connect(_on_restart_pressed)
	gameover_btn_quit.pressed.connect(_on_quit_pressed)

	# Combo label
	combo_label.hide()

	# Wire combo signal
	GameManager.on_combo_broken.connect(_on_combo_broken)

	# Wire hit flash
	GameManager.on_player_hit.connect(_on_player_hit)

	# Wire level up
	GameManager.on_level_up.connect(_on_level_up)

	# Wire shop skip
	weapon_shop.skipped.connect(_on_shop_skipped)

	# Wire weapon fired for crosshair recoil
	GameManager.on_weapon_fired.connect(_on_weapon_fired)

	# Wire achievement unlocks
	GameManager.on_achievement_unlocked.connect(_on_achievement_unlocked)

	# Screen fade in
	fade_overlay.color = Color.BLACK
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 0.0, GameConfig.fade_in_duration).set_delay(GameConfig.fade_in_delay)

	# Pause Menu UI setup
	pause_menu.visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_btn_resume.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_btn_restart.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_btn_main_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_btn_resume.pressed.connect(_on_pause_resume)
	pause_btn_restart.pressed.connect(_on_restart_pressed)
	pause_btn_main_menu.pressed.connect(_on_main_menu)

	print("✅ Game ready, game_over state:", GameManager.is_game_over)


func _process(_delta: float) -> void:
	if not GameManager.is_game_over:
		crosshair_recoil = crosshair_recoil.move_toward(Vector2.ZERO, _delta * GameConfig.crosshair_recoil_recovery)
		crosshair.global_position = get_global_mouse_position() + crosshair_recoil
		camera_2d.global_position = player.global_position
		wave_label.text = "NEXT WAVE IN\n%s" % int(wave_timer.time_left)
		coins_label.text = str(GameManager.coins)
		score_label.text = "Score: %s" % GameManager.score
		enemy_count_label.text = "Enemy: %s" % str(enemy_spawner.enemies_remainig)
		update_combo_display()
		update_xp_bar()
		update_ability_cooldown()
		update_boss_health_bar()
		update_reload_bar()
		update_ammo_label()
		update_low_health_vignette(_delta)
		hud_update_counter += 1
		if hud_update_counter % 5 == 0:
			update_powerup_indicator()


func _input(event) -> void:
	if get_tree().paused:
		if event.is_action_pressed("ui_cancel") and not GameManager.is_game_over:
			_toggle_pause()
		return
	if event.is_action_pressed("ui_cancel") and not GameManager.is_game_over:
		_toggle_pause()


func _toggle_pause() -> void:
	if get_tree().paused:
		pause_menu.visible = false
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.flush_buffered_events()
		game_over_ui.visible = false
		pause_menu.visible = true
		pause_btn_resume.grab_focus()
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		update_stats()


func _on_game_over() -> void:
	print("💀 Game Over triggered and UI shown")
	Input.flush_buffered_events()
	pause_menu.visible = false
	game_over_ui.visible = true
	gameover_btn_restart.disabled = false
	gameover_btn_quit.disabled = false
	gameover_btn_restart.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	print("🛑 Game paused, UI active")

	var is_new_best = GameManager.check_highscore()
	GameManager.save_highscore()
	gameover_score.text = "Final Score: %s" % GameManager.score
	gameover_wave.text = "Wave Reached: %s" % GameManager.current_wave
	gameover_kills.text = "Enemies Killed: %s" % GameManager.total_enemies_killed
	gameover_coins.text = "Coins: %s" % GameManager.coins
	var elapsed = (Time.get_ticks_msec() - GameManager.game_start_time) / 1000.0
	var mins = int(elapsed / 60)
	var secs = int(elapsed) % 60
	gameover_score.text += "\nTime: %02d:%02d" % [mins, secs]
	gameover_highscore.text = "Best: %s" % GameManager.highscore
	gameover_new_best.visible = is_new_best
	boss_health_bar.hide()
	boss_health_label.hide()


func _on_restart_pressed() -> void:
	print("🔄 Restart triggered")
	GameManager.is_game_over = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	print("🚪 Quit triggered")
	get_tree().quit()


func _on_pause_resume() -> void:
	print("⏯️ Resume from pause")
	_toggle_pause()


func _on_main_menu() -> void:
	print("🏠 Main Menu triggered")
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_wave_timer_timeout() -> void:
	if weapon_shop.visible or level_up_ui.visible:
		wave_timer.start()
		return
	weapons.hide()
	wave_label.hide()
	enemy_count_label.show()
	weapon_shop.hide()
	level_up_ui.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	show_wave_announcement()

func _on_shop_skipped() -> void:
	wave_timer.stop()
	_on_wave_timer_timeout()

func show_wave_announcement() -> void:
	var is_boss = GameManager.current_wave > 0 and GameManager.current_wave % GameConfig.boss_wave_interval == 0
	if is_boss:
		wave_announce.text = "⚠ BOSS WAVE ⚠"
		wave_announce.modulate = Color(1, 0.2, 0.2, 1)
	else:
		wave_announce.text = "WAVE %s" % GameManager.current_wave
		wave_announce.modulate = Color(1, 1, 1, 1)
	wave_announce.scale = Vector2(GameConfig.wave_announce_initial_scale, GameConfig.wave_announce_initial_scale)
	wave_announce.show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave_announce, "scale", Vector2(1, 1), GameConfig.wave_announce_scale_in_duration)
	tween.tween_property(wave_announce, "modulate:a", 0, GameConfig.wave_announce_fade_duration).set_delay(GameConfig.wave_announce_fade_delay)
	await tween.finished
	wave_announce.hide()
	enemy_spawner.start_enemy_timer()

func update_combo_display() -> void:
	if GameManager.kill_streak >= GameConfig.combo_min_streak:
		combo_label.text = "x%s COMBO!" % GameManager.kill_streak
		if not combo_label.visible:
			combo_label.show()
			combo_label.scale = Vector2(GameConfig.combo_pop_scale, GameConfig.combo_pop_scale)
			if combo_tween and combo_tween.is_valid():
				combo_tween.kill()
			combo_tween = create_tween()
			combo_tween.tween_property(combo_label, "scale", Vector2(1, 1), GameConfig.combo_normalize_duration)

func update_xp_bar() -> void:
	xp_bar.max_value = GameManager.xp_to_next
	xp_bar.value = GameManager.xp

func update_ability_cooldown() -> void:
	if player and player.ability_cooldown > 0:
		ability_bar.max_value = player.ability_max_cooldown
		ability_bar.value = ability_bar.max_value - player.ability_cooldown
		ability_bar.show()
	else:
		ability_bar.value = ability_bar.max_value
		ability_bar.hide()

func update_powerup_indicator() -> void:
	var active = GameManager.active_powerups
	powerup_indicator.visible = not active.is_empty()
	if active.is_empty():
		return
	var groups: Dictionary = {}
	for entry in active:
		var key = entry["type"]
		if not groups.has(key):
			groups[key] = {"name": entry["name"], "color": entry["color"], "count": 0, "max_remaining": 0.0}
		groups[key]["count"] += 1
		var elapsed = (Time.get_ticks_msec() - entry["start_time"]) / 1000.0
		var remaining = max(0, entry["duration"] - elapsed)
		if remaining > groups[key]["max_remaining"]:
			groups[key]["max_remaining"] = remaining
	var existing = powerup_indicator.get_children()
	var idx = 0
	for key in groups:
		var g = groups[key]
		var label: Label
		if idx < existing.size():
			label = existing[idx]
		else:
			label = POWERUP_LABEL.instantiate()
			powerup_indicator.add_child(label)
		var stack = " x%d" % g["count"] if g["count"] > 1 else ""
		label.text = "%s%s  %ds" % [g["name"], stack, int(g["max_remaining"])]
		label.modulate = g["color"]
		idx += 1
	while idx < existing.size():
		existing[idx].queue_free()
		idx += 1

func update_boss_health_bar() -> void:
	if tracked_boss and is_instance_valid(tracked_boss):
		var hc = tracked_boss.health_component
		boss_health_bar.max_value = hc.max_health
		boss_health_bar.value = hc.current_health
		boss_health_bar.show()
		boss_health_label.show()
		if hc.current_health <= 0:
			tracked_boss = null
			boss_health_bar.hide()
			boss_health_label.hide()
	elif boss_health_bar.visible:
		boss_health_bar.hide()
		boss_health_label.hide()
	elif not tracked_boss:
		var enemies = get_tree().get_nodes_in_group("enemies")
		for e in enemies:
			var enemy = e as Enemy
			if enemy and enemy.is_boss and is_instance_valid(enemy):
				tracked_boss = enemy
				break

func update_ammo_label() -> void:
	if not player:
		return
	var w = player.weapon
	if w.equipped_weapon and w.equipped_weapon.max_ammo > 0:
		ammo_label.text = "%s / %s" % [w.current_ammo, w.equipped_weapon.max_ammo]
		ammo_label.show()
	else:
		ammo_label.hide()

func update_reload_bar() -> void:
	if player and player.weapon.is_reloading:
		reload_bar.max_value = player.weapon.equipped_weapon.reload_time
		reload_bar.value = player.weapon.equipped_weapon.reload_time - player.weapon.delay_btw_shots
		reload_bar.show()
	elif player and player.weapon.equipped_weapon and player.weapon.equipped_weapon.max_ammo > 0:
		reload_bar.hide()

func update_low_health_vignette(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		return
	var health = player.health_component.current_health
	if health <= 0 or health > GameConfig.low_health_threshold:
		vignette.material.set_shader_parameter("MainAlpha", 0.0)
		return
	health_pulse_time += _delta * GameConfig.vignette_pulse_speed
	var pulse = GameConfig.vignette_pulse_alpha_base + sin(health_pulse_time) * GameConfig.vignette_pulse_alpha_range
	vignette.material.set_shader_parameter("MainAlpha", pulse)

func update_stats() -> void:
	if not player:
		return
	stats_speed.text = "Speed: %s" % player.move_speed
	stats_damage.text = "Damage: +%s" % player.damage_bonus
	stats_pierce.text = "Pierce: %s" % player.pierce_bonus
	stats_fire_rate.text = "Fire Rate: +%s%%" % int(player.fire_rate_mod * 100 - 100)
	stats_level.text = "Level: %s" % GameManager.level
	stats_xp.text = "XP: %s/%s" % [GameManager.xp, GameManager.xp_to_next]
	if GameManager.perks_log.is_empty():
		stats_perks.text = "None"
	else:
		stats_perks.text = ", ".join(GameManager.perks_log)

func _on_combo_broken() -> void:
	combo_label.hide()

func _on_weapon_fired(direction: Vector2) -> void:
	crosshair_recoil = -direction * GameConfig.crosshair_recoil_impulse

func _on_level_up() -> void:
	SoundManager.play_levelup()
	GameManager.on_shake_request.emit(GameConfig.level_up_shake)
	var mat = vignette.material as ShaderMaterial
	mat.set_shader_parameter("tint_color", GameConfig.level_up_tint)
	mat.set_shader_parameter("MainAlpha", GameConfig.level_up_vignette_alpha)
	var t = create_tween()
	t.tween_method(func(v): mat.set_shader_parameter("MainAlpha", v), GameConfig.level_up_vignette_alpha, 0.0, GameConfig.level_up_vignette_fade_duration)
	t.tween_callback(func(): mat.set_shader_parameter("tint_color", Color(0, 0, 0, 1)))
	level_up_ui.show_perks()

func _on_achievement_unlocked(ach_id: String) -> void:
	SoundManager.play_achievement_unlock()
	var toast = preload("res://Scenes/AchievementToast.tscn").instantiate()
	for a in GameManager.achievement_defs:
		if a["id"] == ach_id:
			var container = $CanvasLayer/GameUI
			container.add_child(toast)
			toast.setup(a, container.size.x)
			break


func _on_player_hit() -> void:
	hit_flash.color = GameConfig.hit_flash_color
	var tween = create_tween()
	tween.tween_property(hit_flash, "color", Color(1, 0, 0, 0), GameConfig.hit_flash_fade_duration)


func _on_enemy_spawner_on_wave_completed() -> void:
	SoundManager.play_levelup()
	GameManager.check_achievements()
	wave_label.show()
	enemy_count_label.hide()
	wave_timer.start()
	if GameManager.current_wave > 0 and GameManager.current_wave % GameConfig.boss_wave_interval == 0:
		weapons.show()
		weapon_shop.hide()
	else:
		weapons.hide()
		show_weapon_shop()

func show_weapon_shop() -> void:
	weapon_shop.show_shop()
