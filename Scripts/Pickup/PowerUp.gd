extends Area2D
class_name PowerUp

enum Type { SPEED, DAMAGE, INVULN }

@export var power_type: Type = Type.SPEED
@export var lifetime: float = 8.0

var color_map := {
	Type.SPEED: Color(1, 1, 0),
	Type.DAMAGE: Color(1, 0.2, 0.2),
	Type.INVULN: Color(0.2, 0.5, 1),
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	lifetime = GameConfig.powerup_lifetime
	sprite.modulate = color_map[power_type]
	name_label.modulate = color_map[power_type]
	var names = {Type.SPEED: "SPEED", Type.DAMAGE: "DAMAGE", Type.INVULN: "INVULN"}
	name_label.text = names[power_type]
	body_entered.connect(_on_body_entered)
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "modulate:a", GameConfig.powerup_blink_alpha_min, GameConfig.powerup_blink_duration)
	tween.tween_property(sprite, "modulate:a", GameConfig.powerup_blink_alpha_max, GameConfig.powerup_blink_duration)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if not player:
		return
	hide()
	set_deferred("monitoring", false)
	show_pickup_text()
	GameManager.on_shake_request.emit(GameConfig.powerup_pickup_shake)

	var names = {Type.SPEED: "+SPEED", Type.DAMAGE: "+DAMAGE", Type.INVULN: "+INVULN"}
	var durations = {Type.SPEED: GameConfig.powerup_speed_duration, Type.DAMAGE: GameConfig.powerup_damage_duration, Type.INVULN: GameConfig.powerup_invuln_duration}
	var entry = {"type": power_type, "name": names[power_type], "duration": durations[power_type], "start_time": Time.get_ticks_msec(), "color": color_map[power_type]}
	GameManager.active_powerups.append(entry)
	GameManager.on_powerup_started.emit(power_type, names[power_type], durations[power_type], color_map[power_type])

	match power_type:
		Type.SPEED:
			player.move_speed *= GameConfig.powerup_speed_mult
			await get_tree().create_timer(durations[Type.SPEED]).timeout
			if is_instance_valid(player):
				player.move_speed /= GameConfig.powerup_speed_mult
		Type.DAMAGE:
			player.damage_bonus += GameConfig.powerup_damage_bonus
			await get_tree().create_timer(durations[Type.DAMAGE]).timeout
			if is_instance_valid(player):
				player.damage_bonus -= GameConfig.powerup_damage_bonus
		Type.INVULN:
			player.health_component.invulnerable = true
			await get_tree().create_timer(durations[Type.INVULN]).timeout
			if is_instance_valid(player):
				player.health_component.invulnerable = false

	GameManager.active_powerups.erase(entry)
	GameManager.on_powerup_ended.emit(power_type)
	queue_free()

func show_pickup_text() -> void:
	var names = {Type.SPEED: "+SPEED", Type.DAMAGE: "+DAMAGE", Type.INVULN: "+INVULN"}
	var label = preload("res://Scenes/UI/FloatingText.tscn").instantiate()
	label.text = names[power_type]
	label.global_position = global_position - Vector2(50, 0)
	label.modulate = color_map[power_type]
	get_tree().current_scene.add_child(label)
	var t = get_tree().create_tween()
	t.tween_property(label, "position", label.position + Vector2(0, -40), 0.3)
	t.parallel().tween_property(label, "modulate:a", 0, 0.25)
	t.tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
	)
