
extends Node2D

@export var fire_simulation: Node2D
@export var tile_map: TileMapLayer
@export var fire_effect_scene: PackedScene

var active_effects: Dictionary = {}


func _ready() -> void:

	fire_simulation.fire_started.connect(_on_fire_started)
	fire_simulation.fire_finished.connect(_on_fire_finished)


func _on_fire_started(cell: Vector2i) -> void:

	var effect = fire_effect_scene.instantiate()

	get_tree().current_scene.add_child(effect)

	var world_position = tile_map.to_global(
		tile_map.map_to_local(cell)
	)

	effect.global_position = world_position

	active_effects[cell] = effect


func _on_fire_finished(cell: Vector2i) -> void:

	if active_effects.has(cell):

		active_effects[cell].queue_free()

		active_effects.erase(cell)
