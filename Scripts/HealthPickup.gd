extends Area2D

@export var heal_amount: float = 10.0
@export var lifetime: float = 10.0
@export var move_speed: float = 150.0
@export var attract_distance: float = 200.0

var target: Node2D = null
var is_moving_to_player: bool = false

@onready var sprite = $Sprite2D

func _ready() -> void:
	heal_amount = GameConfig.health_pickup_heal_amount
	lifetime = GameConfig.health_pickup_lifetime
	move_speed = GameConfig.health_pickup_move_speed
	attract_distance = GameConfig.health_pickup_attract_distance
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_timer_timeout)
	body_entered.connect(_on_body_entered)
	var circle = CircleShape2D.new()
	circle.radius = GameConfig.health_pickup_collision_radius
	$CollisionShape2D.shape = circle
	$AnimationPlayer.play("pulse")

func _physics_process(delta: float) -> void:
	if not GameManager.player:
		return
		
	var player = GameManager.player
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# If player is close enough, start moving towards them
	if distance_to_player < attract_distance:
		is_moving_to_player = true
		target = player
	
	# Move towards the player if we have a target
	if is_moving_to_player and target:
		var direction = (target.global_position - global_position).normalized()
		position += direction * move_speed * delta

func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		player.heal(heal_amount)
		queue_free()

func _on_timer_timeout() -> void:
	# Create a tween for fade out effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), GameConfig.health_pickup_fade_duration)
	tween.tween_callback(queue_free)
