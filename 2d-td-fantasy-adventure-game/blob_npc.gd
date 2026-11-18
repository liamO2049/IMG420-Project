extends CharacterBody2D

# states
enum State { IDLE, CHASE, DIE, PATROL}
var current_state: State = State.IDLE

# booleans
var is_in_dmg_area = false
var is_action_playing = false

# values
var blobHealth = 100
var patrol_radius = 55
var spawn_position: Vector2 = Vector2.ZERO

# export variables
@export var speed: float = 15.0
@export var timerHitDamage: Timer
@export var timerFindWaypoint: Timer
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area: Area2D = $Area2D
@onready var damage_area: Area2D = $DmgArea

# player
var player = null

var screen_size # Size of the game window.

# Random vector values
var min_x = -1.0
var max_x = 1.0
var min_y = -1.0
var max_y = 1.0

# directio and random point
var direction
var random_point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	timerHitDamage.timeout.connect(_on_timer_timeout_dmg)
	timerFindWaypoint.timeout.connect(_on_timer_timeout)
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	damage_area.body_entered.connect(_on_detection_area_body_entered_dmg)
	damage_area.body_exited.connect(_on_detection_area_body_exited_dmg)
	
	player = get_tree().get_first_node_in_group("player")
	screen_size = get_viewport_rect().size
	print("blob_ai._ready(): detection_area=", detection_area, " monitoring=", detection_area.monitoring, " monitorable=", detection_area.monitorable)
	print("blob_ai._ready(): detection_area collision_layer=", detection_area.collision_layer, " collision_mask=", detection_area.collision_mask)
	print("blob_ai._ready(): initial player found=", player)

	random_point = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
	direction = (random_point - global_position).normalized()
	detection_area.monitoring = true
	detection_area.monitorable = true
	_patrol_timer()

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	if(is_in_dmg_area && timerHitDamage.is_stopped()):
		timerHitDamage.start()
		
	#var overlapping = detection_area.get_overlapping_bodies()
	# if overlapping.size() > 0:
	#	for b in overlapping:
	#		if b.is_in_group("player"):
	#			player = b
	#			current_state = State.CHASE
	#			break
	#else:
	#	if current_state == State.CHASE:
	#		current_state = State.IDLE
	var pos_before = global_position
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("idle")

		State.CHASE:
			direction = (player.global_position - global_position).normalized()
			velocity = direction * (speed * 2)
			$AnimatedSprite2D.play("move")
			
		State.DIE:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("die")
		State.PATROL:
			velocity = direction * speed
			$AnimatedSprite2D.play("move")

	move_and_slide()

func _on_detection_area_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE

func _on_detection_area_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		if player == body:
			player = null
		current_state = State.PATROL
		_on_timer_timeout()
		
func _on_detection_area_body_entered_dmg(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		if player == body:
			is_in_dmg_area = true
			current_state = State.IDLE
		
func _on_detection_area_body_exited_dmg(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		if(player == body):
			is_in_dmg_area = false
			timerHitDamage.stop()
			current_state = State.CHASE
	
func _patrol_timer() -> void:
	await get_tree().create_timer(3.0).timeout
	timerFindWaypoint.start()
	current_state = State.PATROL

func _on_timer_timeout_dmg() -> void:
		player.health -= 10
		print("Player Health Decreased by 10")
		timerHitDamage.stop()

func _on_timer_timeout() -> void:
	random_point = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y)).normalized() * randf_range(50.0, patrol_radius)
	direction = (random_point - spawn_position).normalized()
	timerFindWaypoint.start()
