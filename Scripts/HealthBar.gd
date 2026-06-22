extends ColorRect

@export var delay: float = 0.5
@export var trail_speed: float = 50.0

var _hp: float = 1.0
var _trail: float = 1.0
var _max_hp: float = 100.0
var _delay_expiration: int = 0
var _last_was_heal: bool = false

func setup(max_hp: float, current_hp: float):
	_max_hp = max(max_hp, 1.0)
	_hp = clampf(current_hp / _max_hp, 0.0, 1.0)
	_trail = _hp
	_update_shader()

func set_health(current_hp: float):
	var new_frac = clampf(current_hp / _max_hp, 0.0, 1.0)
	var is_heal = new_frac > _hp
	if is_heal != _last_was_heal:
		var mat = material as ShaderMaterial
		mat.set_shader_parameter("trail", _hp)
		_last_was_heal = is_heal
	_hp = new_frac
	_delay_expiration = Time.get_ticks_msec() + delay * 1000.0
	_update_shader()

func _ready():
	_update_shader()

func _process(delta: float):
	var mat = material as ShaderMaterial
	mat.set_shader_parameter("width", size.x)
	mat.set_shader_parameter("height", size.y)
	var now = Time.get_ticks_msec()
	if now < _delay_expiration:
		return
	var health_frac = _hp
	var trail_frac = _trail
	var dhealth = health_frac - trail_frac
	if abs(dhealth) * _max_hp <= 0.0001:
		return
	if dhealth >= 0.0:
		_trail += delta * trail_speed / _max_hp
		if _trail >= health_frac:
			_trail = health_frac
	else:
		_trail -= delta * trail_speed / _max_hp
		if _trail <= health_frac:
			_trail = health_frac
	mat.set_shader_parameter("trail", _trail)

func _update_shader():
	var mat = material as ShaderMaterial
	if not mat:
		return
	mat.set_shader_parameter("health", _hp)
	mat.set_shader_parameter("width", size.x)
	mat.set_shader_parameter("height", size.y)
