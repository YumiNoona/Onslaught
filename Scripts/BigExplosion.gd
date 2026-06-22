extends ColorRect

signal finished

var _mat: ShaderMaterial
var _duration: float = 3.0
var _size: float = 8.0

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
	var norm = (world_pos - cam_pos) / visible_size + Vector2(0.5, 0.5)
	var aspect = viewport.x / viewport.y
	var disp = Vector2(
		(norm.x - 0.5) / aspect,
		norm.y - 0.4
	) * _size
	_mat.set_shader_parameter("disp", disp)
	_mat.set_shader_parameter("size", _size)
	show()
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_callback(_on_finished).set_delay(_duration)

func _on_finished():
	finished.emit()
	queue_free()
