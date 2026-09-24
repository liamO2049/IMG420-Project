extends CharacterBody2D
signal hit
var last_direction = "down"
var is_action_playing = false

@export var speed = 100 # How fast the player will move (pixels/sec).
@onready var animated_sprite = $AnimatedSprite2D
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	#hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	update_direction(input_direction)
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		if not is_action_playing:
			update_movement_animation(input_direction)
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	
	if velocity.x < 0:
		$AnimatedSprite2D.animation = "run_left"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x > 0
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "run_up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "run_down"
	elif velocity.x > 0:
		$AnimatedSprite2D.animation = "run_right"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	move_and_slide()
	

func update_direction(input_direction):
	if input_direction.y < 0:
		last_direction = "up"
	elif input_direction.y > 0:
		last_direction = "down"
	elif input_direction.x < 0:
		last_direction = "left"
	elif input_direction.x > 0:
		last_direction = "right"
		
func update_movement_animation(input_direction):
	if input_direction == Vector2.ZERO:
		animated_sprite.play("idle_" + last_direction)

func play_action_animation(action_name):
	is_action_playing = true
	animated_sprite.play(action_name + "_" + last_direction)
	
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		play_action_animation("attack")
func _on_animated_sprite_2d_animation_finished() -> void:
	is_action_playing = false
	#else:
		#animated_sprite.play("run_" + last_direction)
#/func _on_body_entered(body: Node2D) -> void:
	#hide() # Player disappears after being hit.
	#hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	#$CollisionShape2D.set_deferred("disabled", true)
	
	
	
#func start(pos):
#	position = pos
#	show()
#	$CollisionShape2D.disabled = false
