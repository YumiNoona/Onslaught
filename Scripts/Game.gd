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
@onready var boss_health_bar: ProgressBar = %BossHealthBar
@onready var boss_health_label: Label = %BossHealthLabel

@onready var stats_speed: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsSpeed
@onready var stats_damage: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsDamage
@onready var stats_pierce: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsPierce
@onready var stats_fire_rate: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsFireRate
@onready var stats_level: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsLevel
@onready var stats_xp: Label = $CanvasLayer/PauseMenu/VBoxContainer/StatsXp
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

var combo_tween: Tween
var crosshair_recoil: Vector2 = Vector2.ZERO
var tracked_boss: Enemy = null
var health_pulse_time: float = 0.0


func _ready() -> void:
	GameManager.reset_game_state()
	var scene = load(GameManager.selected_character_scene) as PackedScene
	player = scene.instantiate()
	player.name = "Player"
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

	# Screen fade in
	fade_overlay.color = Color.BLACK
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 0.0, 0.5).set_delay(0.3)

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
		crosshair_recoil = crosshair_recoil.move_toward(Vector2.ZERO, _delta * 3000)
		crosshair.global_position = get_global_mouse_position() + crosshair_recoil
		camera_2d.global_position = player.global_position
		wave_label.text = "NEW WAVE IN\n%s" % int(wave_timer.time_left)
		coins_label.text = str(GameManager.coins)
		score_label.text = "Score: %s" % GameManager.score
		enemy_count_label.text = "Enemy: %s" % str(enemy_spawner.enemies_remainig)
		update_combo_display()
		update_xp_bar()
		update_ability_cooldown()
		update_powerup_indicator()
		update_boss_health_bar()
		update_reload_bar()
		update_low_health_vignette(_delta)


func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") and not GameManager.is_game_over:
		_toggle_pause()


func _toggle_pause() -> void:
	if get_tree().paused:
		pause_menu.visible = false
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		game_over_ui.visible = false
		pause_menu.visible = true
		pause_btn_resume.grab_focus()
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		update_stats()


func _on_game_over() -> void:
	print("💀 Game Over triggered and UI shown")
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
	var is_boss = GameManager.current_wave > 0 and GameManager.current_wave % 5 == 0
	if is_boss:
		wave_announce.text = "⚠ BOSS WAVE ⚠"
		wave_announce.modulate = Color(1, 0.2, 0.2, 1)
	else:
		wave_announce.text = "WAVE %s" % GameManager.current_wave
		wave_announce.modulate = Color(1, 1, 1, 1)
	wave_announce.scale = Vector2(2, 2)
	wave_announce.show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave_announce, "scale", Vector2(1, 1), 0.4)
	tween.tween_property(wave_announce, "modulate:a", 0, 0.7).set_delay(0.6)
	await tween.finished
	wave_announce.hide()
	enemy_spawner.start_enemy_timer()

func update_combo_display() -> void:
	if GameManager.kill_streak >= 2:
		combo_label.text = "x%s COMBO!" % GameManager.kill_streak
		if not combo_label.visible:
			combo_label.show()
			combo_label.scale = Vector2(1.5, 1.5)
			if combo_tween and combo_tween.is_valid():
				combo_tween.kill()
			combo_tween = create_tween()
			combo_tween.tween_property(combo_label, "scale", Vector2(1, 1), 0.2)

func update_xp_bar() -> void:
	xp_bar.max_value = GameManager.xp_to_next
	xp_bar.value = GameManager.xp

func update_ability_cooldown() -> void:
	if player and player.ability_cooldown > 0:
		ability_bar.max_value = 6.0 if player.character_type == Player.CharacterType.ROCKY else (10.0 if player.character_type == Player.CharacterType.DEFAULT else 2.0)
		ability_bar.value = ability_bar.max_value - player.ability_cooldown
		ability_bar.show()
	else:
		ability_bar.value = ability_bar.max_value
		ability_bar.hide()

func update_powerup_indicator() -> void:
	var active = GameManager.active_powerups
	powerup_indicator.visible = not active.is_empty()
	for child in powerup_indicator.get_children():
		child.queue_free()
	if active.is_empty():
		return
	for entry in active:
		var elapsed = (Time.get_ticks_msec() - entry["start_time"]) / 1000.0
		var remaining = max(0, entry["duration"] - elapsed)
		var label = Label.new()
		label.add_theme_font_override("font", preload("res://Assets/Fonts/kenpixel_mini_square.ttf"))
		label.add_theme_font_size_override("font_size", 20)
		label.text = "%s  %ds" % [entry["name"], int(remaining)]
		label.modulate = entry["color"]
		powerup_indicator.add_child(label)

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
	if health <= 0 or health > 3:
		vignette.material.set_shader_parameter("MainAlpha", 0.0)
		return
	health_pulse_time += _delta * 3.0
	var pulse = 0.3 + sin(health_pulse_time) * 0.15
	vignette.material.set_shader_parameter("MainAlpha", pulse)

func update_stats() -> void:
	if not player:
		return
	stats_speed.text = "Speed: %s" % player.move_speed
	stats_damage.text = "Damage: +%s" % player.damage_bonus
	stats_pierce.text = "Pierce: %s" % (player.pierce_bonus + player.base_pierce if "base_pierce" in player else player.pierce_bonus)
	stats_fire_rate.text = "Fire Rate: +%s%%" % int(player.fire_rate_mod * 100 - 100)
	stats_level.text = "Level: %s" % GameManager.level
	stats_xp.text = "XP: %s/%s" % [GameManager.xp, GameManager.xp_to_next]

func _on_combo_broken() -> void:
	combo_label.hide()

func _on_weapon_fired(direction: Vector2) -> void:
	crosshair_recoil = -direction * 60

func _on_level_up() -> void:
	GameManager.on_shake_request.emit(3.0)
	var mat = vignette.material as ShaderMaterial
	mat.set_shader_parameter("tint_color", Color(1, 0.9, 0, 1))
	mat.set_shader_parameter("MainAlpha", 0.6)
	var t = create_tween()
	t.tween_method(func(v): mat.set_shader_parameter("MainAlpha", v), 0.6, 0.0, 0.5)
	t.tween_callback(func(): mat.set_shader_parameter("tint_color", Color(0, 0, 0, 1)))
	level_up_ui.show_perks()

func _on_player_hit() -> void:
	hit_flash.color = Color(1, 0, 0, 0.35)
	var tween = create_tween()
	tween.tween_property(hit_flash, "color", Color(1, 0, 0, 0), 0.3)


func _on_enemy_spawner_on_wave_completed() -> void:
	wave_label.show()
	enemy_count_label.hide()
	wave_timer.start()
	if GameManager.current_wave > 0 and GameManager.current_wave % 5 == 0:
		weapons.show()
		weapon_shop.hide()
	else:
		weapons.hide()
		show_weapon_shop()

func show_weapon_shop() -> void:
	weapon_shop.show_shop()
