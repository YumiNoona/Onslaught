extends Control

@onready var icon_rect: TextureRect = %IconRect
@onready var fallback: ColorRect = %Fallback
@onready var name_lbl: Label = %NameLabel

var parent_width: float = 0.0
var toast_y: float = 16.0

func setup(data: Dictionary, container_width: float = 0.0) -> void:
	parent_width = container_width
	# Stack below existing toasts
	var offset = 0
	for child in get_parent().get_children():
		if child != self and child is Control and child.visible:
			offset += 1
	toast_y = 16.0 + offset * 80.0
	modulate = Color(1, 1, 1, 0)
	position = Vector2(-size.x, toast_y)

	if data.get("icon") and ResourceLoader.exists(data["icon"]):
		icon_rect.texture = load(data["icon"])
		fallback.hide()
	else:
		fallback.show()

	name_lbl.text = data.get("name", "Achievement Unlocked!")

	var target_x = 16.0
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(target_x, toast_y), 0.3).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.tween_interval(2.5)
	tween.tween_property(self, "position", Vector2(-size.x, toast_y), 0.3)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(queue_free)
