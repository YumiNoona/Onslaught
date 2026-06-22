extends Control

signal accepted(curse: Dictionary)
signal declined

@onready var curse_name: Label = %CurseName
@onready var curse_desc: Label = %CurseDesc
@onready var accept_btn: Button = %AcceptBtn
@onready var decline_btn: Button = %DeclineBtn

var offered_curse: Dictionary = {}

func _ready() -> void:
	accept_btn.pressed.connect(_on_accept)
	decline_btn.pressed.connect(_on_decline)

func offer(curse: Dictionary) -> void:
	offered_curse = curse
	curse_name.text = curse["name"]
	curse_desc.text = curse["desc"]
	show()

func _on_accept() -> void:
	hide()
	accepted.emit(offered_curse)

func _on_decline() -> void:
	hide()
	declined.emit()
