extends Area2D
@export var door_sprite: Sprite2D
@export var door_area: Area2D

func _ready() -> void:
	door_area.body_entered.connect(_on_detection_area_body_entered)


func _on_detection_area_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		door_sprite.visible = false
