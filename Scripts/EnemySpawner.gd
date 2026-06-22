extends Node
class_name EnemySpawner

signal on_wave_completed

const SPAWN_ANIM = preload("res://Scenes/SpawnAnim.tscn")
const BOSS_ENEMY = preload("res://Scenes/Enemy_Boss.tscn")

enum SpawnType {
	RandomTimer,
	FixedTimer
}

@export var spawn_type: SpawnType
@export var min_random: float
@export var max_random: float
@export var fixed_time: float
@export var enemies_per_wave: int = 5

@export var hp_per_wave: float = 2.0
@export var enemy_list: Array[PackedScene] = []
@export var early_wave_enemies: Array[PackedScene] = []
@export var mid_wave_enemies: Array[PackedScene] = []
@onready var spawn_timer: Timer = $SpawnTimer

var enemies_remainig: int
var spawned_enemies: int
var wave_number: int = 0
var pre_boss_count: int = 0
var wave_active: bool = false

func _ready() -> void:
	GameManager.on_enemy_died.connect(_on_enemy_died)
	enemies_per_wave = GameConfig.base_enemies_per_wave
	hp_per_wave = GameConfig.hp_per_wave
	scale_difficulty()
	enemies_remainig = enemies_per_wave
	wave_active = false

func scale_difficulty() -> void:
	wave_number += 1
	GameManager.current_wave = wave_number
	
	if wave_number % GameConfig.boss_wave_interval == 0:
		pre_boss_count = enemies_per_wave
		enemies_per_wave = 1
	else:
		if pre_boss_count > 0:
			enemies_per_wave = pre_boss_count + 1
			pre_boss_count = 0
		else:
			enemies_per_wave += 1
			
	var curse_count_mult = GameManager.active_curse.get("enemy_count_mult", 1.0)
	enemies_per_wave = max(1, ceil(enemies_per_wave * GameManager.difficulty_multiplier * curse_count_mult))
	min_random = max(min_random - 0.1, GameConfig.spawn_timer_min_floor)
	max_random = max(max_random - 0.2, GameConfig.spawn_timer_max_floor)

#Spawn Enemy Fuction

func get_spawn_position() -> Vector2:
	var angle = randf_range(0, TAU)
	var distance = randf_range(GameConfig.spawn_distance_min, GameConfig.spawn_distance_max)
	var pos = GameManager.player.global_position + Vector2(cos(angle), sin(angle)) * distance
	pos.x = clamp(pos.x, -GameConfig.world_bound, GameConfig.world_bound)
	pos.y = clamp(pos.y, -GameConfig.world_bound, GameConfig.world_bound)
	return pos

func spawn_enemy() -> void:
	var spawn_anim: SpawnAnim = SPAWN_ANIM.instantiate()
	var is_boss_wave = wave_number > 0 and wave_number % GameConfig.boss_wave_interval == 0
	var spawn_pos = get_spawn_position() if not is_boss_wave else get_boss_spawn_position()
	spawn_anim.global_position = spawn_pos
	add_child(spawn_anim)
	
	
	await spawn_anim.on_spawn_enemy
	spawn_anim.queue_free()
	
	var random_enemy: PackedScene = BOSS_ENEMY if is_boss_wave else get_tiered_enemy()
	var enemy = random_enemy.instantiate() as Enemy
	if is_boss_wave:
		var boss_types = Enemy.BossType.values()
		var idx = (int(float(wave_number) / GameConfig.boss_wave_interval) - 1) % boss_types.size()
		enemy.boss_type = boss_types[idx]
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
	if is_boss_wave:
		GameManager.on_shake_request.emit(GameConfig.shake_boss_spawn)
		GameManager.on_boss_spawned.emit(enemy)
	else:
		GameManager.on_shake_request.emit(GameConfig.shake_normal_spawn)
	enemy.health_component.current_health += wave_number * hp_per_wave
	enemy.health_component.max_health = enemy.health_component.current_health
	var curse_speed_mult = GameManager.active_curse.get("enemy_speed_mult", 1.0)
	enemy.move_speed *= curse_speed_mult
	var curse_hp_mult = GameManager.active_curse.get("enemy_hp_mult", 1.0)
	var hp = enemy.health_component.current_health
	enemy.health_component.current_health = hp * curse_hp_mult
	enemy.health_component.max_health = enemy.health_component.current_health
	if is_boss_wave:
		enemy.move_speed += wave_number * GameConfig.boss_speed_per_wave
		var atk_timer = enemy.get_node_or_null("BossAttackTimer")
		if atk_timer:
			atk_timer.wait_time = max(GameConfig.boss_attack_cooldown_min, GameConfig.boss_attack_cooldown_base - wave_number * GameConfig.boss_attack_cooldown_per_wave)
	
	spawned_enemies +=1
	start_enemy_timer()

func get_boss_spawn_position() -> Vector2:
	var angle = randf_range(0, TAU)
	var distance = randf_range(GameConfig.boss_spawn_distance_min, GameConfig.boss_spawn_distance_max)
	var pos = GameManager.player.global_position + Vector2(cos(angle), sin(angle)) * distance
	pos.x = clamp(pos.x, -GameConfig.world_bound, GameConfig.world_bound)
	pos.y = clamp(pos.y, -GameConfig.world_bound, GameConfig.world_bound)
	return pos
	
func get_tiered_enemy() -> PackedScene:
	var pool: Array[PackedScene] = []
	if wave_number <= GameConfig.tier_early_only_max:
		if not early_wave_enemies.is_empty():
			for i in range(5):
				pool.append(early_wave_enemies.pick_random())
	elif wave_number <= GameConfig.tier_mid_only_max:
		if not early_wave_enemies.is_empty():
			pool.append(early_wave_enemies.pick_random())
		if not mid_wave_enemies.is_empty():
			for i in range(4):
				pool.append(mid_wave_enemies.pick_random())
	else:
		if not mid_wave_enemies.is_empty():
			pool.append(mid_wave_enemies.pick_random())
		if not enemy_list.is_empty():
			for i in range(5):
				pool.append(enemy_list.pick_random())
	return pool.pick_random()

func start_enemy_timer() -> void:
	wave_active = true
	spawn_timer.wait_time = get_new_time()
	var curse_spawn_mult = GameManager.active_curse.get("spawn_speed_mult", 1.0)
	spawn_timer.wait_time *= curse_spawn_mult
	spawn_timer.start()
	
	
func has_wave_enemies_left() -> bool:
	return wave_active or enemies_remainig > 0
	
	
func get_new_time() -> float:
	var time: float
	if spawn_type == SpawnType.RandomTimer:
		time = randf_range(min_random, max_random)
	else:
		time = fixed_time
		
	return time


func _on_spawn_timer_timeout() -> void:
	if spawned_enemies >= enemies_per_wave:
		return
		
	spawn_enemy()

func _on_enemy_died() -> void:
	if not wave_active:
		return
	enemies_remainig -= 1
	if enemies_remainig <= 0:
		wave_active = false
		spawn_timer.stop()
		await get_tree().create_timer(GameConfig.wave_completion_delay).timeout
		scale_difficulty()
		on_wave_completed.emit()
		enemies_remainig = enemies_per_wave
		spawned_enemies = 0
