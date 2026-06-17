extends CharacterBody2D
class_name Enemy

@export var move_speed := 400.0

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar
@onready var anim_sprite: AnimatedSprite2D = $AnimSprite
@onready var area_2d: Area2D = $Area2D

@export var contact_damage: float = 1.0
@export var damage_cooldown: float = 1.5

# Healer enemy
@export var is_healer: bool = false
# Boss enemy
@export var is_boss: bool = false
var enraged: bool = false
const BOSS_BULLET = preload("res://Scenes/Bullet.tscn")
@export var heal_range: float = 200.0
@export var heal_amount: float = 3.0
@export var heal_cooldown: float = 4.0
var is_healing: bool = false

var can_move := true
var players_in_contact: Array[Player] = []
var damage_timers: Dictionary = {}

func _ready() -> void:
	add_to_group("enemies")
	if is_healer:
		var timer = Timer.new()
		timer.name = "HealPulseTimer"
		timer.wait_time = heal_cooldown
		timer.timeout.connect(_on_heal_pulse)
		add_child(timer)
		timer.start()
	if is_boss:
		var timer = Timer.new()
		timer.name = "BossAttackTimer"
		timer.wait_time = GameConfig.boss_attack_cooldown_base
		timer.timeout.connect(_on_boss_attack)
		add_child(timer)
		timer.start()

func _physics_process(_delta: float) -> void:
	var player_direction = GameManager.player.global_position - global_position
	
	if player_direction.length() <= GameConfig.enemy_stop_distance or not can_move:
		velocity = Vector2.ZERO
		return
	
	var direction = player_direction.normalized()
	velocity = direction * move_speed
	
	move_and_slide()
	anim_sprite.flip_h = true if velocity.x < 0 else false

func _on_health_component_on_damaged() -> void:
	var health_value := health_component.current_health / health_component.max_health
	health_bar.set_value(health_value)
	anim_sprite.material = GameManager.HIT_MATERIAL
	if is_boss and not enraged and health_component.current_health <= health_component.max_health * GameConfig.boss_enrage_threshold:
		enraged = true
		move_speed *= GameConfig.boss_enrage_speed_mult
		var t = get_node_or_null("BossAttackTimer")
		if t:
			t.wait_time = GameConfig.boss_enraged_attack_cooldown
	await get_tree().create_timer(GameConfig.hit_flash_duration).timeout
	anim_sprite.material = null

func _on_health_component_on_defeated() -> void:
	can_move = false
	anim_sprite.play("Death")
	collision_shape_2d.set_deferred("disabled", true)
	if is_boss:
		for i in range(GameConfig.boss_coin_drop_min + randi() % GameConfig.boss_coin_drop_max):
			GameManager.create_coin(global_position)
	else:
		GameManager.create_coin(global_position)
	if not is_healer and randf() < GameConfig.powerup_drop_chance:
		spawn_powerup()
	GameManager.add_score(int(GameConfig.score_per_kill_base * max(GameManager.current_wave, 1)))
	GameManager.add_xp(int(GameConfig.xp_per_kill_base * max(GameManager.current_wave, 1)))
	GameManager.increment_combo()
	GameManager.total_enemies_killed += 1
	spawn_death_particles()
	GameManager.play_explosion_anim(global_position)
	GameManager.on_shake_request.emit(GameConfig.shake_boss_death if is_boss else GameConfig.shake_enemy_death)
	if is_boss:
		Engine.time_scale = GameConfig.boss_death_time_scale
		await get_tree().create_timer(GameConfig.boss_death_duration, false, false, true).timeout
		Engine.time_scale = 1.0
	health_bar.hide()
	
	# Clean up all damage timers
	for timer in damage_timers.values():
		if is_instance_valid(timer):
			timer.queue_free()
	damage_timers.clear()
	players_in_contact.clear()
	
	await anim_sprite.animation_finished
	GameManager.on_enemy_died.emit()
	queue_free()

func spawn_death_particles() -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = GameConfig.death_particles_amount
	particles.lifetime = GameConfig.death_particles_lifetime
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = GameConfig.death_particles_velocity_min
	particles.initial_velocity_max = GameConfig.death_particles_velocity_max
	particles.scale_amount_min = GameConfig.death_particles_scale_min
	particles.scale_amount_max = GameConfig.death_particles_scale_max
	particles.color = Color(0.8, 0.1, 0.1, 0.8) if not is_boss else Color(1, 0.5, 0, 0.9)
	particles.color_ramp = null
	particles.gravity = Vector2(0, GameConfig.death_particles_gravity_y)
	particles.z_index = 15
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime + 0.2).timeout
	if is_instance_valid(particles):
		particles.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var player = body as Player
	if not player:
		return


	if player not in players_in_contact:
		players_in_contact.append(player)
		deal_contact_damage(player)
		start_damage_timer(player)

func _on_area_2d_body_exited(body: Node2D) -> void:
	var player = body as Player
	if not player:
		return
	

	if player in players_in_contact:
		players_in_contact.erase(player)

		if player in damage_timers:
			var timer = damage_timers[player]
			if is_instance_valid(timer):
				timer.queue_free()
			damage_timers.erase(player)

func start_damage_timer(player: Player) -> void:
	var timer = Timer.new()
	timer.wait_time = damage_cooldown
	timer.one_shot = false
	timer.timeout.connect(func(): deal_contact_damage(player))
	add_child(timer)
	timer.start()
	damage_timers[player] = timer

func deal_contact_damage(player: Player) -> void:
	if not is_instance_valid(player) or player not in players_in_contact:
		return
	
	player.health_component.take_damage(contact_damage)
	GameManager.play_damage_text(player.global_position, int(contact_damage))

func spawn_powerup() -> void:
	var power = preload("res://Scenes/PowerUp.tscn").instantiate()
	power.global_position = global_position
	power.power_type = randi() % PowerUp.Type.size()
	get_parent().call_deferred("add_child", power)

func _on_boss_attack() -> void:
	if not can_move or GameManager.is_game_over:
		return
	var bullet = BOSS_BULLET.instantiate()
	bullet.global_position = global_position
	bullet.damage = contact_damage
	bullet.pierce = 0
	bullet.is_enemy_bullet = true
	bullet.move_direction = (GameManager.player.global_position - global_position).normalized()
	get_parent().add_child(bullet)

func _on_heal_pulse() -> void:
	if is_healing or not is_healer:
		return
	is_healing = true

	var affected: Array[Node] = []
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy == self:
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= heal_range:
			var e = enemy as Enemy
			if e and e.health_component.current_health < e.health_component.max_health:
				e.health_component.current_health = min(
					e.health_component.current_health + heal_amount,
					e.health_component.max_health
				)
				if is_instance_valid(e.anim_sprite):
					e.anim_sprite.material = GameManager.HEAL_MATERIAL
					affected.append(e)

	if not affected.is_empty():
		await get_tree().create_timer(GameConfig.hit_flash_duration).timeout
		for e in affected:
			if is_instance_valid(e) and is_instance_valid(e.anim_sprite):
				e.anim_sprite.material = null

	is_healing = false
