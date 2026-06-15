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
@onready var hit_flash: ColorRect = $CanvasLayer/HitFlash
@onready var level_up_ui: Control = $CanvasLayer/LevelUpUI
@onready var weapon_shop: Control = $CanvasLayer/WeaponShop
@onready var fade_overlay: ColorRect = $CanvasLayer/FadeOverlay

# Game Over UI
@onready var game_over_ui: Control = $CanvasLayer/GameOverUI
@onready var gameover_btn_restart: Button = $CanvasLayer/GameOverUI/VBoxContainer/BTN_Restart
@onready var gameover_btn_quit: Button = $CanvasLayer/GameOverUI/VBoxContainer/BTN_Quit

# Pause Menu UI
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var pause_btn_resume: Button = $CanvasLayer/PauseMenu/VBoxContainer/BTN_Resume
@onready var pause_btn_restart: Button = $CanvasLayer/PauseMenu/VBoxContainer/BTN_Restart
@onready var pause_btn_main_menu: Button = $CanvasLayer/PauseMenu/VBoxContainer/BTN_MainMenu

# Preload main menu for faster transition
var main_menu_scene := preload("res://Scenes/MainMenu.tscn")

var combo_tween: Tween
var crosshair_recoil: Vector2 = Vector2.ZERO


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

	# Show final score on game over screen
	var score_display = game_over_ui.get_node_or_null("VBoxContainer/ScoreDisplay")
	if score_display:
		score_display.text = "Final Score: %s" % GameManager.score


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
	weapons.hide()
	wave_label.hide()
	enemy_count_label.show()
	weapon_shop.hide()
	level_up_ui.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	show_wave_announcement()

func show_wave_announcement() -> void:
	wave_announce.text = "WAVE %s" % GameManager.current_wave
	wave_announce.scale = Vector2(2, 2)
	wave_announce.modulate = Color(1, 1, 1, 1)
	wave_announce.show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave_announce, "scale", Vector2(1, 1), 0.4)
	tween.tween_property(wave_announce, "modulate", Color(1, 1, 1, 0), 0.7).set_delay(0.6)
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

func _on_combo_broken() -> void:
	combo_label.hide()

func _on_weapon_fired(direction: Vector2) -> void:
	crosshair_recoil = -direction * 60

func _on_level_up() -> void:
	if not level_up_ui.has_meta("setup"):
		level_up_ui.set_meta("setup", true)
		level_up_ui.set_script(load("res://Scripts/LevelUpUI.gd"))
	level_up_ui.show_perks()

func _on_player_hit() -> void:
	hit_flash.color = Color(1, 0, 0, 0.35)
	var tween = create_tween()
	tween.tween_property(hit_flash, "color", Color(1, 0, 0, 0), 0.3)


func _on_enemy_spawner_on_wave_completed() -> void:
	weapons.show()
	wave_label.show()
	enemy_count_label.hide()
	wave_timer.start()
	show_weapon_shop()

func show_weapon_shop() -> void:
	if not weapon_shop.has_meta("setup"):
		weapon_shop.set_meta("setup", true)
		weapon_shop.set_script(load("res://Scripts/WeaponShop.gd"))
	weapon_shop.show_shop()
