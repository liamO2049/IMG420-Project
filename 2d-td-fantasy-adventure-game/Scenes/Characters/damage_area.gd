extends Area2D

var blob
@export var player: CharacterBody2D
@export var detection_area: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_detection_area_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("blob"):
		blob = body
		player.health -= 5
