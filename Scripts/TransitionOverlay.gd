extends ColorRect

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func play_transition(duration: float = 0.6, target_scene: PackedScene = null):
	var mat = material as ShaderMaterial
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(func(v): mat.set_shader_parameter("t", v), 0.0, 1.0, duration)
	if target_scene:
		tween.tween_callback(func(): get_tree().change_scene_to_packed(target_scene))
