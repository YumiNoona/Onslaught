extends Control
class_name HealthBar

@onready var progress_bar: ProgressBar = $ProgressBar

func set_value(v: float) -> void:
	progress_bar.value = v
