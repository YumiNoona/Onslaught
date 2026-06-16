extends Resource
class_name WeaponData

@export var gun_name: String
@export var gun_sprite: Texture
@export var gun_colour: Color
@export var buy_price: int
@export var damage: float
@export var delay_between_shots: float
@export var fire_pos: Vector2
@export var bullet_scene: PackedScene
@export var pierce: int = 0
@export var max_ammo: int = -1
@export var reload_time: float = 1.0
@export var bullet_count: int = 1
@export var spread_angle: float = 0.0
