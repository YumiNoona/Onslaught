extends Area2D
class_name PowerUp

@export var power_data: PowerUpData

var _target_player: Node2D = null
var _is_magnetic: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	if not power_data:
		push_error("PowerUp missing power_data!")
		return
		
	sprite.texture = power_data.icon
	sprite.modulate = power_data.color
	name_label.modulate = power_data.color
	name_label.text = power_data.powerup_name
	body_entered.connect(_on_body_entered)
	
	var _start_y = sprite.position.y
	var bob_tween = create_tween().set_loops()
	bob_tween.tween_property(sprite, "position:y", _start_y - 10.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(sprite, "position:y", _start_y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "modulate:a", GameConfig.powerup_blink_alpha_min, GameConfig.powerup_blink_duration)
	tween.tween_property(sprite, "modulate:a", GameConfig.powerup_blink_alpha_max, GameConfig.powerup_blink_duration)
	get_tree().create_timer(power_data.lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if not power_data or not power_data.is_magnetic or not GameManager.player:
		return
	
	var player = GameManager.player
	if _target_player == null and global_position.distance_to(player.global_position) < power_data.magnet_distance:
		_target_player = player
		_is_magnetic = true
	
	if _is_magnetic and _target_player:
		var dir = (_target_player.global_position - global_position).normalized()
		position += dir * power_data.magnet_speed * delta

func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if not player or not power_data:
		return
	hide()
	set_deferred("monitoring", false)
	show_pickup_text()
	GameManager.on_shake_request.emit(GameConfig.powerup_pickup_shake)

	var entry = {"type": power_data.effect_type, "name": "+" + power_data.powerup_name, "duration": power_data.effect_duration, "start_time": Time.get_ticks_msec(), "color": power_data.color}
	GameManager.active_powerups.append(entry)
	GameManager.on_powerup_started.emit(power_data.effect_type, "+" + power_data.powerup_name, power_data.effect_duration, power_data.color)

	player.apply_buff_effect(power_data.color)

	match power_data.effect_type:
		PowerUpData.EffectType.SPEED:
			player.move_speed *= power_data.effect_value
			await get_tree().create_timer(power_data.effect_duration).timeout
			if is_instance_valid(player):
				player.move_speed /= power_data.effect_value
		PowerUpData.EffectType.DAMAGE:
			player.damage_bonus += power_data.effect_value
			await get_tree().create_timer(power_data.effect_duration).timeout
			if is_instance_valid(player):
				player.damage_bonus -= power_data.effect_value
		PowerUpData.EffectType.INVULN:
			player.health_component.invulnerable = true
			await get_tree().create_timer(power_data.effect_duration).timeout
			if is_instance_valid(player):
				player.health_component.invulnerable = false
		PowerUpData.EffectType.HEAL:
			player.heal(power_data.effect_value, false)

	GameManager.active_powerups.erase(entry)
	GameManager.on_powerup_ended.emit(power_data.effect_type)
	queue_free()

func show_pickup_text() -> void:
	if not power_data:
		return
	var label = preload("res://Scenes/UI/FloatingText.tscn").instantiate()
	label.text = "+" + power_data.powerup_name
	label.global_position = global_position - Vector2(50, 0)
	label.modulate = power_data.color
	get_tree().current_scene.add_child(label)
	var t = get_tree().create_tween()
	t.tween_property(label, "position", label.position + Vector2(0, -40), 0.3)
	t.parallel().tween_property(label, "modulate:a", 0, 0.25)
	t.tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
	)
