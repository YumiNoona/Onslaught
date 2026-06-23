extends CanvasLayer

var overlay: ColorRect
var _slash_mat: ShaderMaterial

const OVERLAY_SCENE = preload("res://Scenes/Core/TransitionOverlay.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay = OVERLAY_SCENE.instantiate()
	var vp_w = ProjectSettings.get_setting("display/window/size/viewport_width", 1920)
	var vp_h = ProjectSettings.get_setting("display/window/size/viewport_height", 1080)
	var aspect = float(vp_w) / float(vp_h) if vp_h > 0 else 1.0

	var slash_shader = preload("res://Material/TransitionSlash.gdshader")
	_slash_mat = ShaderMaterial.new()
	_slash_mat.shader = slash_shader
	_slash_mat.set_shader_parameter("t", 0.0)
	_slash_mat.set_shader_parameter("power", 8.0)
	_slash_mat.set_shader_parameter("normal", Vector2(0.6, 1.0))
	_slash_mat.set_shader_parameter("offset", -0.5)

	overlay.material = _slash_mat
	add_child(overlay)

func transition_to(scene: PackedScene, duration: float = 0.5):
	var colors = [Color(0.1, 0.1, 0.15), Color(0.2, 0.1, 0.1), Color(0.1, 0.2, 0.1), Color(0.2, 0.2, 0.1), Color(0.1, 0.1, 0.2)]
	var rand_color = colors[randi() % colors.size()]
	_slash_mat.set_shader_parameter("mask_color", rand_color)
	
	overlay.material = _slash_mat
	_slash_mat.set_shader_parameter("t", 0.0)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _slash_mat.set_shader_parameter("t", v), 0.0, 1.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.finished.connect(func(): get_tree().change_scene_to_packed(scene), CONNECT_ONE_SHOT)

func fade_in(duration: float = 0.5):
	overlay.material = _slash_mat
	_slash_mat.set_shader_parameter("t", 1.0)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _slash_mat.set_shader_parameter("t", v), 1.0, 0.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
