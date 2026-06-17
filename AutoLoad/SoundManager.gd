extends Node

var click: AudioStream
var levelup: AudioStream


func _ready() -> void:
	click = load("res://Assets/Sound/click.wav")
	levelup = load("res://Assets/Sound/levelup.wav")


func play(sound: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = sound
	player.bus = "SFX"
	add_child(player)
	player.play()
	await player.finished
	if is_instance_valid(player):
		player.queue_free()


func play_click() -> void:
	play(click)


func play_levelup() -> void:
	play(levelup)


func play_achievement_unlock() -> void:
	play(levelup)
