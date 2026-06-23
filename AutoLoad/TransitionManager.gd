extends CanvasLayer

var overlay: ColorRect
var _slash_mat: ShaderMaterial
var _current_color: Color

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

func transition_to(scene: PackedScene, _duration: float = 0.9):
	_current_color = TRANSITION_COLORS[randi() % TRANSITION_COLORS.size()]
	_slash_mat.set_shader_parameter("mask_color", _current_color)
	_slash_mat.set_shader_parameter("normal", Vector2(1.0, 0.5))
	_slash_mat.set_shader_parameter("t", 0.0)
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _slash_mat.set_shader_parameter("t", v), 0.0, 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tw.finished
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(scene)

func clear() -> void:
	_slash_mat.set_shader_parameter("t", 0.0)

func fade_in(_duration: float = 0.7):
	_slash_mat.set_shader_parameter("mask_color", _current_color)
	_slash_mat.set_shader_parameter("normal", Vector2(1.0, 0.5))
	_slash_mat.set_shader_parameter("t", 1.0)
	await get_tree().process_frame
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v): _slash_mat.set_shader_parameter("t", v), 1.0, 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
