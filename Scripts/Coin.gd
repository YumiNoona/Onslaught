extends Area2D
class_name Coin

@export var coin_value: int = 1
@export var magnet_radius: float = 300.0
@export var magnet_speed: float = 600.0
@onready var pickup: AudioStreamPlayer = $Pickup


func _physics_process(delta: float) -> void:
	if not GameManager.player:
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
