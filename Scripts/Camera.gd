extends Camera2D

@export var shake_delay := 0.5
@export var shake_strength := 0.05
@export var shake_max_roll := 0.15

var trauma: float
var can_shake: bool

func _ready() -> void:
	GameManager.on_shake_request.connect(_on_shake_request)

func _physics_process(delta: float) -> void:
	if can_shake:
		trauma = max(trauma - shake_max_roll * delta, 0.0)
		shake_camera()

func shake_camera() -> void:
	var amount := trauma
	rotation = shake_max_roll * amount * randf_range(-1.0, 1.0)
	offset.x = 15 * amount * randf_range(-1.0, 1.0)
	offset.y = 15 * amount * randf_range(-1.0, 1.0)

func _on_shake_request(multiplier: float = 1.0) -> void:
	trauma = clamp(shake_strength * multiplier, 0.0, 1.0)
	can_shake = true
