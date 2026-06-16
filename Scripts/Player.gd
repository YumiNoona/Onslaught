extends CharacterBody2D
class_name Player

enum CharacterType { DEFAULT, ROCKY, SIMON }

@export var character_type: CharacterType = CharacterType.DEFAULT
@export var move_speed := 700.0
@export var max_health: float = 10.0:
	set(v):
		max_health = v
		if health_component:
			health_component.max_health = v
@export var health_on_level_up: float = 1.0
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon: Weapon = $Weapon
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar
@onready var collision: CollisionShape2D = $CollisionShape2D

var can_move: bool = true
var mouse_pos: Vector2

# Perk bonus stats
var pierce_bonus: int = 0
var damage_bonus: float = 0.0
@export var fire_rate_mod: float = 1.0

# Character ability
var ability_cooldown: float = 0.0
var ability_max_cooldown: float = 10.0

# Dash
@export var dash_speed: float = 1500.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0
var is_dashing: bool = false
var can_dash: bool = true

# Footstep
var footstep_timer: float = 0.0

func _ready():
	health_component.max_health = max_health
	health_component.current_health = max_health
	await get_tree().process_frame
	print("Player ready, can_move:", can_move)

func _physics_process(_delta: float) -> void:
	if not can_move or GameManager.is_game_over:
		return

	if Input.is_action_just_pressed("Dash") and can_dash and not is_dashing:
		start_dash()

	if Input.is_action_just_pressed("Interact") and ability_cooldown <= 0 and not is_dashing and not GameManager.is_game_over:
		use_ability()

	var input := Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")

	if is_dashing:
		move_and_slide()
		return

	velocity = input.normalized() * move_speed
	move_and_slide()

	if velocity.length() > 10:
		footstep_timer -= _delta
		if footstep_timer <= 0:
			footstep_timer = 0.3
			play_footstep()

func start_dash() -> void:
	var dir = Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT if anim_sprite.flip_h else Vector2.LEFT
	is_dashing = true
	can_dash = false
	health_component.invulnerable = true
	velocity = dir.normalized() * dash_speed
	anim_sprite.material = GameManager.HIT_MATERIAL

	var trail = Line2D.new()
	trail.default_color = Color(1, 1, 1, 0.5)
	trail.width = 6
	trail.z_index = -1
	get_tree().root.add_child(trail)
	var elapsed = 0.0
	while elapsed < dash_duration:
		trail.add_point(global_position)
		if trail.get_point_count() > 15:
			trail.remove_point(0)
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	is_dashing = false
	health_component.invulnerable = false
	if is_instance_valid(anim_sprite):
		anim_sprite.material = null

	if is_instance_valid(trail):
		var fade = create_tween()
		fade.tween_property(trail, "default_color:a", 0, 0.15)
		await fade.finished
		trail.queue_free()

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func setup_weapon(weapon_data: WeaponData) -> void:
	weapon.setup(weapon_data)
	weapon.show()

func _process(_delta: float) -> void:
	if ability_cooldown > 0:
		ability_cooldown -= _delta
	if not can_move or GameManager.is_game_over:
		return
	get_mouse_pos()
	update_animations()
	update_rotation()
	update_weapon_rotation()

func play_footstep() -> void:
	var player = AudioStreamPlayer2D.new()
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050
	player.stream = gen
	player.max_distance = 400
	player.volume_db = -12 + randf_range(-3, 3)
	get_tree().root.add_child(player)
	player.play()
	var playback = player.get_stream_playback()
	var frames = 400
	var buf = PackedVector2Array()
	for i in frames:
		var t = float(i) / frames
		var amp = max(0, 1.0 - t * 5.0) * 0.15
		buf.append(Vector2(randf_range(-amp, amp), randf_range(-amp, amp)))
	playback.push_buffer(buf)
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(player):
		player.queue_free()

func use_ability() -> void:
	match character_type:
		CharacterType.ROCKY:
			ground_slam()
		CharacterType.SIMON:
			quick_dash()
		_:
			adrenaline_rush()

func adrenaline_rush() -> void:
	ability_cooldown = 10.0
	ability_max_cooldown = 10.0
	move_speed *= 1.2
	fire_rate_mod += 0.2
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(self):
		move_speed /= 1.2
		fire_rate_mod -= 0.2

func ground_slam() -> void:
	ability_cooldown = 6.0
	ability_max_cooldown = 6.0
	anim_sprite.material = GameManager.HIT_MATERIAL
	GameManager.on_shake_request.emit(3.0)

	var ring = Sprite2D.new()
	ring.texture = preload("res://Assets/Sprites/light.png")
	ring.position = global_position
	ring.modulate = Color(1, 0.6, 0.2, 0.8)
	ring.scale = Vector2(0.1, 0.1)
	ring.z_index = 10
	get_tree().root.add_child(ring)
	var ring_tween = create_tween()
	ring_tween.tween_property(ring, "scale", Vector2(6, 6), 0.3)
	ring_tween.parallel().tween_property(ring, "modulate:a", 0, 0.3)
	ring_tween.tween_callback(ring.queue_free)

	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		var enemy = e as Enemy
		if not enemy or not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= 300:
			enemy.health_component.take_damage(3)
			GameManager.play_damage_text(enemy.global_position, 3)
			var dir = (enemy.global_position - global_position).normalized()
			enemy.velocity = dir * 800
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(anim_sprite):
		anim_sprite.material = null

func quick_dash() -> void:
	ability_cooldown = 2.0
	ability_max_cooldown = 2.0
	var dir = Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT if anim_sprite.flip_h else Vector2.LEFT
	health_component.invulnerable = true
	velocity = dir.normalized() * dash_speed * 1.5
	anim_sprite.material = GameManager.HIT_MATERIAL

	var trail = Line2D.new()
	trail.default_color = Color(0.6, 0.8, 1, 0.6)
	trail.width = 6
	trail.z_index = -1
	get_tree().root.add_child(trail)
	var elapsed = 0.0
	while elapsed < 0.15:
		trail.add_point(global_position)
		if trail.get_point_count() > 10:
			trail.remove_point(0)
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	if is_instance_valid(self):
		health_component.invulnerable = false
	if is_instance_valid(anim_sprite):
		anim_sprite.material = null
	if is_instance_valid(trail):
		var fade = create_tween()
		fade.tween_property(trail, "default_color:a", 0, 0.1)
		await fade.finished
		trail.queue_free()

func get_mouse_pos() -> void:
	mouse_pos = get_global_mouse_position()

func update_rotation() -> void:
	anim_sprite.flip_h = mouse_pos.x < global_position.x

func update_weapon_rotation() -> void:
	weapon.rotate_weapon(mouse_pos.x < global_position.x)
	weapon.look_at(mouse_pos)

func update_animations() -> void:
	anim_sprite.play("Move" if velocity.length() > 0 else "Idle")

func _on_health_component_on_damaged() -> void:
	var health_value := health_component.current_health / health_component.max_health
	health_bar.set_value(health_value)
	anim_sprite.material = GameManager.HIT_MATERIAL
	GameManager.on_shake_request.emit(2.0)
	GameManager.on_player_hit.emit()
	await get_tree().create_timer(0.3).timeout
	anim_sprite.material = null

func heal(amount: float) -> void:
	if not is_instance_valid(health_component):
		return
		
	health_component.current_health = min(health_component.current_health + amount, health_component.max_health)
	var health_value = health_component.current_health / health_component.max_health
	health_bar.set_value(health_value)
	
	# Show healing effect
	anim_sprite.material = GameManager.HEAL_MATERIAL
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(anim_sprite):
		anim_sprite.material = null

func _on_health_component_on_defeated() -> void:
	print("Player defeated")
	if GameManager.is_game_over:
		return
		
	anim_sprite.play("Death")
	can_move = false
	health_bar.hide()

	Engine.time_scale = 0.2
	await get_tree().create_timer(1.0, false, false, true).timeout
	Engine.time_scale = 1.0

	GameManager.is_game_over = true
	weapon.set_process(false)
	weapon.set_physics_process(false)
	if is_instance_valid(weapon):
		weapon.call_deferred("queue_free")
	
	collision.set_deferred("disabled", true)
	GameManager.call_deferred("emit_signal", "on_game_over")
