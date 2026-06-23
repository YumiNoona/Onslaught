extends Node2D
class_name Weapon

@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var fire_pos: Marker2D = $FirePos
@onready var fire_audio: AudioStreamPlayer = $FireAudio
@onready var anim_player: AnimationPlayer = $"../AnimationPlayer"


var equipped_weapon: WeaponData
var delay_btw_shots: float
var original_fire_pos: Vector2
var current_ammo: int = -1
var reserve_ammo: int = 0
var max_reserve_ammo: int = 0
var is_reloading: bool = false
var reload_elapsed: float = 0.0
var reload_bar_visible: bool = false

func _process(delta: float) -> void:
	if not equipped_weapon:
		return
	delay_btw_shots = max(delay_btw_shots - delta, 0)

	if is_reloading:
		reload_elapsed += delta
		if reload_elapsed >= equipped_weapon.reload_time:
			if equipped_weapon.max_ammo > 0:
				var needed = equipped_weapon.max_ammo - current_ammo
				var amount_to_reload = min(needed, reserve_ammo)
				current_ammo += amount_to_reload
				reserve_ammo -= amount_to_reload
			is_reloading = false
			reload_bar_visible = false
		return

	reload_bar_visible = false
	if equipped_weapon.max_ammo > 0 and current_ammo <= 0 and reserve_ammo > 0:
		start_reload()
		return

	if delay_btw_shots > 0:
		return

	if Input.is_action_pressed("Shoot"):
		if equipped_weapon.max_ammo <= 0 or current_ammo > 0:
			shoot_weapon()
	if Input.is_action_just_pressed("Reload"):
		start_reload()

func get_reload_progress() -> float:
	if not is_reloading or equipped_weapon.reload_time <= 0:
		return 0.0
	return clamp(reload_elapsed / equipped_weapon.reload_time, 0.0, 1.0)

func setup(weapon_data: WeaponData) -> void:
	equipped_weapon = weapon_data
	weapon_sprite.texture = weapon_data.gun_sprite
	weapon_sprite.self_modulate = weapon_data.gun_colour
	delay_btw_shots = weapon_data.delay_between_shots
	fire_pos.position = weapon_data.fire_pos
	original_fire_pos = weapon_data.fire_pos
	current_ammo = weapon_data.max_ammo
	if weapon_data.max_ammo > 0:
		reserve_ammo = weapon_data.max_ammo * 3
		max_reserve_ammo = weapon_data.max_ammo * 5
	else:
		reserve_ammo = 0
		max_reserve_ammo = 0
	is_reloading = false
	reload_elapsed = 0.0
	reload_bar_visible = false

func start_reload() -> void:
	if is_reloading or equipped_weapon.max_ammo <= 0:
		return
	if current_ammo == equipped_weapon.max_ammo:
		return
	if reserve_ammo <= 0:
		return
	is_reloading = true
	reload_elapsed = 0.0
	reload_bar_visible = true

func shoot_weapon() -> void:
	if equipped_weapon.max_ammo > 0:
		current_ammo -= 1
	var dir = (get_global_mouse_position() - global_position).normalized()
	var b_count = min(equipped_weapon.bullet_count, 8)
	var spread = equipped_weapon.spread_angle
	for i in b_count:
		var bullet: Bullet = equipped_weapon.bullet_scene.instantiate()
		bullet.global_position = fire_pos.global_position
		var curse_damage_mult = GameManager.active_curse.get("damage_mult", 1.0)
		bullet.damage = (equipped_weapon.damage + GameManager.player.damage_bonus) * curse_damage_mult
		bullet.pierce = equipped_weapon.pierce + GameManager.player.pierce_bonus
		bullet.crit_chance = equipped_weapon.crit_chance + GameManager.player.crit_bonus
		
		var offset = randf_range(-spread, spread) if spread > 0 else 0.0
		bullet.move_direction = dir.rotated(deg_to_rad(offset))
		
		get_tree().current_scene.add_child(bullet)
	fire_audio.play()
	anim_player.play("Shoot")
	GameManager.on_shake_request.emit(equipped_weapon.damage / 3.0)
	GameManager.on_weapon_fired.emit(dir)
	var curse_fr = GameManager.active_curse.get("fire_rate_bonus", 0.0)
	delay_btw_shots = max(equipped_weapon.delay_between_shots / (GameManager.player.fire_rate_mod + curse_fr), 0.05)

	call_deferred("_play_muzzle_flash")

func _play_muzzle_flash() -> void:
	weapon_sprite.material = GameManager.HIT_MATERIAL
	await get_tree().create_timer(GameConfig.muzzle_flash_duration).timeout
	if is_instance_valid(weapon_sprite):
		weapon_sprite.material = null
	
	
func rotate_weapon(value: bool) -> void:
	if value:
		weapon_sprite.flip_v = true
		fire_pos.position.y = abs(original_fire_pos.y)
	else:
		weapon_sprite.flip_v = false
		fire_pos.position.y = -abs(original_fire_pos.y)
	fire_pos.position.x = original_fire_pos.x
