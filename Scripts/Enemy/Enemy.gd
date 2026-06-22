extends CharacterBody2D
class_name Enemy

enum BossType { TELEPORTER, DASHER, SUMMONER, BARRAGE }

const BOSS_NAMES = {
	BossType.TELEPORTER: "The Marauder",
	BossType.DASHER: "The Juggernaut",
	BossType.SUMMONER: "The Archon",
	BossType.BARRAGE: "The Artillery",
}

@export var move_speed := 400.0

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar
@onready var anim_sprite: AnimatedSprite2D = $AnimSprite
@onready var area_2d: Area2D = $Area2D
@onready var shadow_sprite: Sprite2D = $Shadow

@export var contact_damage: float = 1.0
@export var damage_cooldown: float = 1.5

# Healer enemy
@export var is_healer: bool = false
# Boss enemy
@export var is_boss: bool = false
@export var boss_type: BossType = BossType.TELEPORTER
var enraged: bool = false
const BOSS_BULLET = preload("res://Scenes/Weapon/Bullet.tscn")
const HEALTH_PICKUP = preload("res://Scenes/Pickup/HealthPickup.tscn")
const MINION_ENEMY = preload("res://Scenes/Enemy/Enemy_Mob.tscn")
@export var heal_range: float = 200.0
@export var heal_amount: float = 3.0
@export var heal_cooldown: float = 4.0
var is_healing: bool = false

var _is_dead := false
var can_move := true
var players_in_contact: Array[Player] = []
var damage_timers: Dictionary = {}
var _boss_ability_timer: Timer

func _ready() -> void:
	add_to_group("enemies")
	_setup_outline_size()
	if is_boss:
		health_bar.hide()
	if is_healer:
		var timer = Timer.new()
		timer.name = "HealPulseTimer"
		timer.wait_time = heal_cooldown
		timer.timeout.connect(_on_heal_pulse)
		add_child(timer)
		timer.start()
	if is_boss:
		_boss_ability_timer = Timer.new()
		_boss_ability_timer.name = "BossAbilityTimer"
		_boss_ability_timer.wait_time = _get_ability_cooldown()
		_boss_ability_timer.timeout.connect(_on_boss_ability)
		add_child(_boss_ability_timer)
		_boss_ability_timer.start()
		var atk_timer = Timer.new()
		atk_timer.name = "BossAttackTimer"
		atk_timer.wait_time = GameConfig.boss_attack_cooldown_base
		atk_timer.timeout.connect(_on_boss_attack)
		add_child(atk_timer)
		atk_timer.start()

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
	var prev_mat = anim_sprite.material
	anim_sprite.material = GameManager.HIT_MATERIAL
	if is_boss and not enraged and health_component.current_health <= health_component.max_health * GameConfig.boss_enrage_threshold:
		enraged = true
		move_speed *= GameConfig.boss_enrage_speed_mult
		var t = get_node_or_null("BossAttackTimer")
		if t:
			t.wait_time = GameConfig.boss_enraged_attack_cooldown
	await get_tree().create_timer(GameConfig.hit_flash_duration).timeout
	if is_instance_valid(anim_sprite) and not _is_dead:
		anim_sprite.material = prev_mat

func _on_health_component_on_defeated() -> void:
	_is_dead = true
	can_move = false
	anim_sprite.play("Death")
	# Hide sprite when "Death" animation finishes
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("Death"):
		var death_len = anim_sprite.sprite_frames.get_frame_count("Death") / max(anim_sprite.sprite_frames.get_animation_speed("Death"), 0.001)
		if not anim_sprite.animation_finished.is_connected(_on_death_anim_finished):
			anim_sprite.animation_finished.connect(_on_death_anim_finished)
		# Fallback timer in case animation is not looping but signal doesn't fire
		if death_len > 0:
			get_tree().create_timer(death_len, false, false, true).timeout.connect(_on_death_timer_timeout)
	else:
		anim_sprite.hide()
	collision_shape_2d.set_deferred("disabled", true)
	area_2d.set_deferred("monitoring", false)
	if is_instance_valid(shadow_sprite):
		shadow_sprite.hide()
	if is_boss:
		for i in range(GameConfig.boss_coin_drop_min + randi() % GameConfig.boss_coin_drop_max):
			GameManager.create_coin(global_position)
	else:
		GameManager.create_coin(global_position)
	if not is_healer and randf() < GameConfig.powerup_drop_chance:
		spawn_powerup()
	if not is_healer and randf() < GameConfig.health_pickup_drop_chance:
		spawn_health_pickup()
	GameManager.add_score(int(GameConfig.score_per_kill_base * max(GameManager.current_wave, 1)))
	GameManager.add_xp(int(GameConfig.xp_per_kill_base * max(GameManager.current_wave, 1)))
	GameManager.total_enemies_killed += 1
	GameManager.increment_combo()
	# Refill weapon magazine on kill
	var p_weapon = GameManager.player.weapon
	if p_weapon and p_weapon.equipped_weapon and p_weapon.equipped_weapon.max_ammo > 0:
		p_weapon.current_ammo = p_weapon.equipped_weapon.max_ammo
	spawn_death_particles()
	var big_explosion: Node = null
	if is_boss:
		big_explosion = GameManager.play_big_explosion(global_position)
	else:
		GameManager.play_explosion_anim(global_position)
	GameManager.on_shake_request.emit(GameConfig.shake_boss_death if is_boss else GameConfig.shake_enemy_death)
	if is_boss:
		Engine.time_scale = GameConfig.boss_death_time_scale
		await get_tree().create_timer(GameConfig.boss_death_duration, false, false, true).timeout
		Engine.time_scale = 1.0
		if big_explosion and is_instance_valid(big_explosion):
			await big_explosion.finished
	health_bar.hide()
	
	# Clean up all damage timers
	for timer in damage_timers.values():
		if is_instance_valid(timer):
			timer.queue_free()
	damage_timers.clear()
	players_in_contact.clear()
	
	GameManager.on_enemy_died.emit()
	queue_free()

func _on_death_anim_finished() -> void:
	if anim_sprite.animation == "Death":
		anim_sprite.hide()

func _on_death_timer_timeout() -> void:
	if is_instance_valid(anim_sprite) and anim_sprite.visible:
		anim_sprite.hide()

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
	get_tree().create_timer(particles.lifetime + 0.2).timeout.connect(particles.queue_free)


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
	var power = preload("res://Scenes/Pickup/PowerUp.tscn").instantiate()
	power.global_position = global_position
	power.power_type = randi() % PowerUp.Type.size()
	get_parent().call_deferred("add_child", power)

func spawn_health_pickup() -> void:
	var hp = HEALTH_PICKUP.instantiate()
	hp.global_position = global_position
	get_parent().call_deferred("add_child", hp)

func _get_ability_cooldown() -> float:
	match boss_type:
		BossType.TELEPORTER: return 3.0
		BossType.DASHER: return 4.0
		BossType.SUMMONER: return 6.0
		BossType.BARRAGE: return 5.0
	return 4.0

func _on_boss_attack() -> void:
	if not can_move or GameManager.is_game_over:
		return
	if boss_type == BossType.BARRAGE:
		for i in 5:
			var angle = randf_range(-0.3, 0.3)
			var dir = (GameManager.player.global_position - global_position).normalized().rotated(angle)
			var b = BOSS_BULLET.instantiate()
			b.global_position = global_position
			b.damage = contact_damage * 0.6
			b.pierce = 0
			b.is_enemy_bullet = true
			b.move_direction = dir
			get_parent().add_child(b)
	else:
		var bullet = BOSS_BULLET.instantiate()
		bullet.global_position = global_position
		bullet.damage = contact_damage
		bullet.pierce = 0
		bullet.is_enemy_bullet = true
		bullet.move_direction = (GameManager.player.global_position - global_position).normalized()
		get_parent().add_child(bullet)

func _on_boss_ability() -> void:
	if not can_move or GameManager.is_game_over or not is_instance_valid(GameManager.player):
		return
	match boss_type:
		BossType.TELEPORTER:
			_do_teleport()
		BossType.DASHER:
			_do_dash()
		BossType.SUMMONER:
			_do_summon()
		BossType.BARRAGE:
			pass
	_boss_ability_timer.wait_time = _get_ability_cooldown()
	_boss_ability_timer.start()

func _do_teleport() -> void:
	var player = GameManager.player
	var angle = randf_range(0, TAU)
	var dist = randf_range(200, 400)
	var target = player.global_position + Vector2(cos(angle), sin(angle)) * dist
	target.x = clamp(target.x, -GameConfig.world_bound, GameConfig.world_bound)
	target.y = clamp(target.y, -GameConfig.world_bound, GameConfig.world_bound)
	global_position = target
	anim_sprite.material = GameManager.HIT_MATERIAL
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(anim_sprite):
		anim_sprite.material = null

func _do_dash() -> void:
	if not is_instance_valid(GameManager.player):
		return
	var dir = (GameManager.player.global_position - global_position).normalized()
	var target = global_position + dir * 500
	target.x = clamp(target.x, -GameConfig.world_bound, GameConfig.world_bound)
	target.y = clamp(target.y, -GameConfig.world_bound, GameConfig.world_bound)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(self, "global_position", target, 0.3)
	can_move = false
	await tw.finished
	can_move = true

func _do_summon() -> void:
	var count = 2 + randi() % 2
	for i in count:
		var minion = MINION_ENEMY.instantiate()
		var angle = randf_range(0, TAU)
		var dist = randf_range(100, 200)
		minion.global_position = global_position + Vector2(cos(angle), sin(angle)) * dist
		minion.move_speed *= 0.6
		minion.scale *= 0.7
		var hp = 1 + GameManager.current_wave
		minion.health_component.max_health = hp
		minion.health_component.current_health = hp
		get_parent().add_child(minion)
		GameManager.on_minion_spawned.emit()

func _on_heal_pulse() -> void:
	if is_healing or not is_healer:
		return
	is_healing = true

	var affected: Array[Dictionary] = []
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
					affected.append({"node": e, "prev_mat": e.anim_sprite.material})
					e.anim_sprite.material = GameManager.HEAL_MATERIAL

	if not affected.is_empty():
		await get_tree().create_timer(GameConfig.hit_flash_duration).timeout
		for entry in affected:
			var e = entry["node"] as Enemy
			if is_instance_valid(e) and is_instance_valid(e.anim_sprite) and not e._is_dead:
				e.anim_sprite.material = entry["prev_mat"]

	is_healing = false

func _setup_outline_size():
	var mat = anim_sprite.material as ShaderMaterial
	if not mat:
		return
	if not anim_sprite.sprite_frames:
		return
	var tex = anim_sprite.sprite_frames.get_frame_texture("Move", 0)
	if tex:
		mat.set_shader_parameter("texture_size", tex.get_size())
