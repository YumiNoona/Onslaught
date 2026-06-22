extends Node
class_name HealthComponent

signal on_defeated 
signal on_damaged

@export var max_health := 10.0
@export var current_health : float = 10.0
var invulnerable: bool = false

func _ready() -> void:
	if current_health <= 0:
		current_health = max_health
	
func take_damage(value: float) -> void:
		if current_health <=0 or invulnerable:
			return
			
		current_health -= value
		on_damaged.emit()
		
		if current_health<= 0:
			current_health = 0
			on_defeated.emit()
