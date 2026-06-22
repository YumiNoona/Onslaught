extends ColorRect

var max_value: float = 1.0:
	set(v):
		max_value = v
		_update_shader()
var value: float = 1.0:
	set(v):
		value = v
		_update_shader()

func _ready():
	resized.connect(_update_shader)
	_update_shader()

func _update_shader():
	if not material:
		return
	var mat = material as ShaderMaterial
	mat.set_shader_parameter("panel_size", size)
	mat.set_shader_parameter("fill_progress", value / max_value if max_value > 0.0 else 0.0)
