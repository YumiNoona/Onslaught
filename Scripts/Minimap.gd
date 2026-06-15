extends Control

@export var map_size: float = 1000.0
@export var radar_radius: float = 80.0

func _draw() -> void:
	if not GameManager.player:
		return
	var center = size / 2
	draw_circle(center, radar_radius, Color(0, 0, 0, 0.5))
	draw_arc(center, radar_radius, 0, TAU, 32, Color(1, 1, 1, 0.3))
	var player_pos = GameManager.player.global_position
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var offset = (enemy.global_position - player_pos) / map_size * radar_radius
		offset = offset.clamp(Vector2(-radar_radius + 4, -radar_radius + 4), Vector2(radar_radius - 4, radar_radius - 4))
		draw_circle(center + offset, 3, Color(1, 0.2, 0.2))
	draw_circle(center, 4, Color(1, 1, 1))

func _process(_delta: float) -> void:
	queue_redraw()
