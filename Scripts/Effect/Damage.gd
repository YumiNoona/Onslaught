extends Control
class_name DamageText

@onready var damage_label: Label = $DamageLabel

func setup(value: int, is_crit: bool = false) -> void:
	damage_label.text = str(value)
	if is_crit:
		damage_label.label_settings = damage_label.label_settings.duplicate()
		damage_label.label_settings.font_color = Color(1, 0.8, 0, 1)
		damage_label.label_settings.font_size = 80
