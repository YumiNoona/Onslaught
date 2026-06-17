extends Control

@export var map_size: float = 1000.0
@export var radar_radius: float = 80.0

func _ready() -> void:
	map_size = GameConfig.minimap_map_size
	radar_radius = GameConfig.minimap_radar_radius

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
		offset = offset.clamp(Vector2(-radar_radius + GameConfig.minimap_dot_clamp_margin, -radar_radius + GameConfig.minimap_dot_clamp_margin), Vector2(radar_radius - GameConfig.minimap_dot_clamp_margin, radar_radius - GameConfig.minimap_dot_clamp_margin))
		draw_circle(center + offset, GameConfig.minimap_enemy_dot_radius, Color(1, 0.2, 0.2))
	draw_circle(center, GameConfig.minimap_player_dot_radius, Color(1, 1, 1))

func _process(_delta: float) -> void:
	queue_redraw()
