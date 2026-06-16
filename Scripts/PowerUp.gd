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

func _ready() -> void:
	sprite.modulate = color_map[power_type]
	body_entered.connect(_on_body_entered)
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "modulate:a", 0.3, 0.4)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.4)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if not player:
		return
	show_pickup_text()
	GameManager.on_shake_request.emit(1.0)

	var names = {Type.SPEED: "+SPEED", Type.DAMAGE: "+DAMAGE", Type.INVULN: "+INVULN"}
	var durations = {Type.SPEED: 5.0, Type.DAMAGE: 5.0, Type.INVULN: 3.0}
	var entry = {"type": power_type, "name": names[power_type], "duration": durations[power_type], "start_time": Time.get_ticks_msec(), "color": color_map[power_type]}
	GameManager.active_powerups.append(entry)
	GameManager.on_powerup_started.emit(power_type, names[power_type], durations[power_type], color_map[power_type])

	match power_type:
		Type.SPEED:
			player.move_speed *= 1.5
			await get_tree().create_timer(durations[Type.SPEED]).timeout
			if is_instance_valid(player):
				player.move_speed /= 1.5
		Type.DAMAGE:
			player.damage_bonus += 3
			await get_tree().create_timer(durations[Type.DAMAGE]).timeout
			if is_instance_valid(player):
				player.damage_bonus -= 3
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
	var label = Label.new()
	label.text = names[power_type]
	label.add_theme_font_override("font", preload("res://Assets/Fonts/kenpixel_mini_square.ttf"))
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.global_position = global_position - Vector2(50, 0)
	label.modulate = color_map[power_type]
	label.z_index = 20
	get_tree().current_scene.add_child(label)
	var t = create_tween()
	t.tween_property(label, "position", label.position + Vector2(0, -40), 0.6)
	t.parallel().tween_property(label, "modulate:a", 0, 0.6)
	t.tween_callback(label.queue_free)
