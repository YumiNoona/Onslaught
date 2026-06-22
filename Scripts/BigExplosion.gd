extends ColorRect

var _mat: ShaderMaterial

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mat = material as ShaderMaterial
	if not _mat:
		var shader = preload("res://Material/CartoonExplosion.gdshader")
		_mat = ShaderMaterial.new()
		_mat.shader = shader
		material = _mat

func trigger(world_pos: Vector2, camera: Camera2D):
	if not _mat:
		_ready()
	var viewport = get_viewport_rect().size
	var cam_pos = camera.global_position
	var zoom = camera.zoom
	var visible_size = viewport * zoom
	var rel = (world_pos - cam_pos) / visible_size
	var uv = rel + Vector2(0.5, 0.5)
	_mat.set_shader_parameter("disp", uv - Vector2(0.5, 0.4))
	show()
	var tw = create_tween()
	tw.tween_callback(queue_free).set_delay(1.2)
