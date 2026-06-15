extends Node2D
class_name Weapon

@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var fire_pos: Marker2D = $FirePos
@onready var fire_audio: AudioStreamPlayer = $FireAudio
@onready var anim_player: AnimationPlayer = $"../AnimationPlayer"


var equipped_weapon: WeaponData
var delay_btw_shots: float

func _process(delta: float) -> void:
	delay_btw_shots-= delta
	if delay_btw_shots<= 0:
		if not equipped_weapon: return
		if Input.is_action_pressed("Shoot"):
			shoot_weapon()

func setup(weapon_data: WeaponData) -> void:
	equipped_weapon = weapon_data
	weapon_sprite.texture = weapon_data.gun_sprite
	weapon_sprite.self_modulate = weapon_data.gun_colour
	delay_btw_shots = weapon_data.delay_between_shots
	fire_pos.position = weapon_data.fire_pos
	
	
func shoot_weapon() -> void:
	var dir = (get_global_mouse_position() - global_position).normalized()
	var bullet: Bullet = equipped_weapon.bullet_scene.instantiate()
	bullet.global_position = fire_pos.global_position
	bullet.damage = equipped_weapon.damage + GameManager.player.damage_bonus
	bullet.pierce = equipped_weapon.pierce + GameManager.player.pierce_bonus
	bullet.move_direction = dir
	fire_audio.play()
	anim_player.play("Shoot")
	GameManager.on_shake_request.emit(equipped_weapon.damage / 3.0)
	GameManager.on_weapon_fired.emit(dir)
	get_tree().root.add_child(bullet)
	delay_btw_shots = equipped_weapon.delay_between_shots / GameManager.player.fire_rate_mod

	# Muzzle flash
	weapon_sprite.material = GameManager.HIT_MATERIAL
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(weapon_sprite):
		weapon_sprite.material = null
	
	
func rotate_weapon(value: bool ) -> void:
	if value:
		weapon_sprite.flip_v = true
		fire_pos.position.y = 50
	else:
		weapon_sprite.flip_v = false
		fire_pos.position.y = -50
