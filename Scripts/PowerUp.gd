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
	match power_type:
		Type.SPEED:
			player.move_speed *= 1.5
			await get_tree().create_timer(5.0).timeout
			if is_instance_valid(player):
				player.move_speed /= 1.5
		Type.DAMAGE:
			player.damage_bonus += 3
			await get_tree().create_timer(5.0).timeout
			if is_instance_valid(player):
				player.damage_bonus -= 3
		Type.INVULN:
			player.health_component.invulnerable = true
			await get_tree().create_timer(3.0).timeout
			if is_instance_valid(player):
				player.health_component.invulnerable = false
	queue_free()
