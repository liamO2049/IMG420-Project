extends Sprite2D

@export var rotation_speed: float = 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += rotation_speed * delta
