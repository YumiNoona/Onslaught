extends Node

var click: AudioStream
var levelup: AudioStream

const POOL_SIZE := 8
var _pool: Array[AudioStreamPlayer] = []
var _pool_index := 0

func _ready() -> void:
	click = load("res://Assets/Sound/click.wav")
	levelup = load("res://Assets/Sound/levelup.wav")
	for i in POOL_SIZE:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_pool.append(p)

func play(sound: AudioStream) -> void:
	var p = _pool[_pool_index]
	_pool_index = (_pool_index + 1) % _pool.size()
	p.stream = sound
	p.play()

func play_click() -> void:
	play(click)

func play_levelup() -> void:
	play(levelup)

func play_achievement_unlock() -> void:
	play(levelup)
