extends CanvasLayer

var overlay: ColorRect
var _slash_mat: ShaderMaterial

const OVERLAY_SCENE = preload("res://Scenes/Core/TransitionOverlay.tscn")

const TRANSITION_COLORS = [
	Color(0.05, 0.05, 0.12),
	Color(0.15, 0.05, 0.05),
	Color(0.05, 0.12, 0.05),
	Color(0.15, 0.15, 0.05),
	Color(0.05, 0.05, 0.15),
	Color(0.12, 0.05, 0.12),
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay = OVERLAY_SCENE.instantiate()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_slash_mat = overlay.material as ShaderMaterial
	add_child(overlay)

func transition_to(scene: PackedScene, duration: float = 0.9):
	var rand_color = TRANSITION_COLORS[randi() % TRANSITION_COLORS.size()]
	_slash_mat.set_shader_parameter("mask_color", rand_color)
	_slash_mat.set_shader_parameter("t", 0.0)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _slash_mat.set_shader_parameter("t", v), 0.0, 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.finished.connect(func(): get_tree().change_scene_to_packed(scene), CONNECT_ONE_SHOT)

func fade_in(duration: float = 0.7):
	_slash_mat.set_shader_parameter("t", 1.0)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _slash_mat.set_shader_parameter("t", v), 1.0, 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
