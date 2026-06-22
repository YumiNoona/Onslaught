extends Control

@export var map_size: float = 1000.0
@export var radar_radius: float = 80.0
@export var update_interval: int = 3

var enemy_dots: Array[ColorRect] = []
var frame_count: int = 0

@onready var player_dot: ColorRect = $PlayerDot
@onready var enemy_container: Node2D = $EnemyContainer


func _ready() -> void:
	player_dot.hide()
	queue_redraw()


func _draw() -> void:
	var center = size / 2
	draw_circle(center, radar_radius, Color(0, 0, 0, 0.5))
	draw_arc(center, radar_radius, 0, TAU, 64, Color(1, 1, 1, 0.3), 2.0)


func _process(_delta: float) -> void:
	if not GameManager.player:
		return
	frame_count += 1
	if frame_count % update_interval != 0:
		return
	var enemies = get_tree().get_nodes_in_group("enemies")
	var visible_count = 0
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var offset = (enemy.global_position - GameManager.player.global_position) / map_size * radar_radius
		offset = offset.clamp(Vector2(-radar_radius + 4, -radar_radius + 4), Vector2(radar_radius - 4, radar_radius - 4))
		var dot: ColorRect
		if visible_count < enemy_dots.size():
			dot = enemy_dots[visible_count]
			dot.show()
		else:
			dot = ColorRect.new()
			dot.color = Color(1, 0.2, 0.2)
			dot.custom_minimum_size = Vector2(6, 6)
			dot.size = Vector2(6, 6)
			enemy_container.add_child(dot)
			enemy_dots.append(dot)
		dot.position = size / 2 + offset - dot.size / 2
		visible_count += 1
	while visible_count < enemy_dots.size():
		enemy_dots[visible_count].hide()
		visible_count += 1
