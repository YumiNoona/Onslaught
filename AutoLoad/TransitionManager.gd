extends CanvasLayer

var overlay: ColorRect
var _mat: ShaderMaterial

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay = ColorRect.new()
	overlay.name = "TransitionOverlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	var sz = DisplayServer.window_get_size()
	overlay.custom_minimum_size = sz
	var shader = preload("res://Material/CircleWipe.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("radius", 0.0)
	mat.set_shader_parameter("center", Vector2(0.5, 0.5))
	mat.set_shader_parameter("aspect", sz.x / sz.y if sz.y > 0 else 1.0)
	overlay.material = mat
	_mat = mat
	add_child(overlay)

func transition_to(scene: PackedScene, duration: float = 0.5):
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _mat.set_shader_parameter("radius", v), 0.0, 0.8, duration)
	await tw.finished
	get_tree().change_scene_to_packed(scene)

func fade_in(duration: float = 0.5):
	_mat.set_shader_parameter("radius", 0.8)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _mat.set_shader_parameter("radius", v), 0.8, 0.0, duration)
