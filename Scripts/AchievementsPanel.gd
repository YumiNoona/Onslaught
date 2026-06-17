extends Control

@onready var container: VBoxContainer = %AchievementList
@onready var back_btn: Button = %BackBtn

const ROW_SCENE = preload("res://Scenes/AchievementRow.tscn")

func _ready() -> void:
	back_btn.pressed.connect(func(): hide())

func populate() -> void:
	for c in container.get_children():
		c.queue_free()
	for a in GameManager.achievement_defs:
		var row = ROW_SCENE.instantiate()
		row.setup(a)
		container.add_child(row)
