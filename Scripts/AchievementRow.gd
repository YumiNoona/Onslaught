extends HBoxContainer

@onready var icon_rect: TextureRect = %IconRect
@onready var name_lbl: Label = %NameLabel
@onready var desc_lbl: Label = %DescLabel
@onready var status_lbl: Label = %StatusLabel

func setup(data: Dictionary) -> void:
	if data["icon"] and ResourceLoader.exists(data["icon"]):
		icon_rect.texture = load(data["icon"])
		icon_rect.modulate = Color(1, 1, 1, 1) if data["unlocked"] else Color(0.3, 0.3, 0.3, 0.5)
		icon_rect.visible = true
	else:
		icon_rect.visible = false
	name_lbl.text = data["name"]
	desc_lbl.text = data["desc"]
	name_lbl.modulate = Color(1, 1, 1, 1) if data["unlocked"] else Color(0.5, 0.5, 0.5, 1)
	status_lbl.text = "✓" if data["unlocked"] else "✗"
	status_lbl.modulate = Color(0, 1, 0, 1) if data["unlocked"] else Color(0.5, 0.1, 0.1, 1)
