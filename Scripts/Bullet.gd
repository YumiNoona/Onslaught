extends Node2D
class_name  Bullet

@export var speed: = 1000.0
@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound
@onready var trail: Line2D = $Trail

var move_direction: Vector2
var damage: float
var pierce: int = 0
var trail_positions: Array[Vector2] = []
var is_enemy_bullet: bool = false

func _ready() -> void:
	$Area2D.collision_mask = 2 if is_enemy_bullet else 4

func _process(delta: float) -> void:
	if move_direction == Vector2.ZERO:
		return
	position += move_direction * speed * delta
	trail_positions.append(global_position)
	if trail_positions.size() > 8:
		trail_positions.pop_front()
	trail.points = trail_positions


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_enemy_bullet:
		var enemy = body as Enemy
		if enemy:
			enemy.health_component.take_damage(damage)
			GameManager.play_damage_text(global_position, int(damage))
			spawn_hit_spark()
			Engine.time_scale = 0.05
			await get_tree().create_timer(0.02, true, false, true).timeout
			Engine.time_scale = 1.0
			if pierce > 0:
				pierce -= 1
				return
	else:
		var player = body as Player
		if player:
			player.health_component.take_damage(damage)
			GameManager.play_damage_text(global_position, int(damage))
			queue_free()
			return

	GameManager.play_explosion_anim(global_position)
	explosion_sound.play()
	await get_tree().create_timer(.08).timeout
	queue_free()

func spawn_hit_spark() -> void:
	var spark = Sprite2D.new()
	spark.texture = preload("res://Assets/Sprites/light.png")
	spark.global_position = global_position
	spark.scale = Vector2(0.15, 0.15)
	spark.modulate = Color(1, 1, 0.5, 1)
	spark.z_index = 10
	get_tree().root.add_child(spark)
	var t = create_tween()
	t.tween_property(spark, "modulate:a", 0, 0.1)
	t.tween_property(spark, "scale", Vector2(0.4, 0.4), 0.1)
	t.tween_callback(spark.queue_free)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
