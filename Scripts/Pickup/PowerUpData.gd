extends Resource
class_name PowerUpData

enum EffectType { SPEED, DAMAGE, INVULN, HEAL }

@export var powerup_name: String = "PowerUp"
@export var icon: Texture2D
@export var color: Color = Color.WHITE
@export var effect_type: EffectType = EffectType.SPEED
@export var effect_value: float = 1.0
@export var effect_duration: float = 5.0
@export var lifetime: float = 8.0

@export_group("Magnet Effect")
@export var is_magnetic: bool = false
@export var magnet_distance: float = 200.0
@export var magnet_speed: float = 150.0
