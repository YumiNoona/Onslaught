extends Area2D
class_name Coin

@export var coin_value: int = 1
@export var magnet_radius: float = 300.0
@export var magnet_speed: float = 600.0
var bounce_velocity: Vector2
@onready var pickup: AudioStreamPlayer = $Pickup


func _ready() -> void:
	coin_value = GameConfig.coin_value
	magnet_radius = GameConfig.magnet_radius
	magnet_speed = GameConfig.magnet_speed
	bounce_velocity = Vector2(randf_range(GameConfig.coin_bounce_velocity_x_min, GameConfig.coin_bounce_velocity_x_max), randf_range(GameConfig.coin_bounce_velocity_y_min, GameConfig.coin_bounce_velocity_y_max))

func _process(delta: float) -> void:
	if not GameManager.player:
		return
	if bounce_velocity.length_squared() > 1.0:
		global_position += bounce_velocity * delta
		bounce_velocity *= GameConfig.coin_friction
		return
	var dist = global_position.distance_to(GameManager.player.global_position)
	if dist < magnet_radius:
		var dir = (GameManager.player.global_position - global_position).normalized()
		global_position += dir * magnet_speed * delta

func _on_body_entered(_body: Node2D) -> void:
	GameManager.add_coins(coin_value)
	pickup.play()
	await pickup.finished
	queue_free()
