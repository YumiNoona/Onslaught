extends Area2D
class_name Coin

@export var coin_value: int = 1
@export var magnet_radius: float = 300.0
@export var magnet_speed: float = 600.0
var bounce_velocity: Vector2
@onready var pickup: AudioStreamPlayer = $Pickup


func _ready() -> void:
	bounce_velocity = Vector2(randf_range(-300, 300), randf_range(-400, -100))

func _process(delta: float) -> void:
	if not GameManager.player:
		return
	if bounce_velocity.length_squared() > 1.0:
		global_position += bounce_velocity * delta
		bounce_velocity *= 0.92
		return
	var dist = global_position.distance_to(GameManager.player.global_position)
	if dist < magnet_radius:
		var dir = (GameManager.player.global_position - global_position).normalized()
		global_position += dir * magnet_speed * delta

func _on_body_entered(_body: Node2D) -> void:
	GameManager.coins += coin_value
	pickup.play()
	await pickup.finished
	queue_free()
