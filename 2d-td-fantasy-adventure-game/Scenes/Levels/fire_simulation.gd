
extends Node2D

signal fire_started(cell: Vector2i)
signal fire_finished(cell: Vector2i)

@export var tile_map: TileMapLayer
@export var tick_interval: float = 0.5
@export_range(0.0, 1.0) var spread_chance: float = 0.4

@onready var timer: Timer = $Timer

# Stores each burning tile and its remaining burn time.
var burning_cells: Dictionary = {}

@export var burnt_source_id: int = 1
@export var burnt_atlas_coords: Vector2i = Vector2i(3, 2)
@export var burnt_alternative_tile: int = 0

# Four neighboring directions.
var directions: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

func _ready() -> void:
	timer.wait_time = tick_interval
	timer.timeout.connect(_on_timer_timeout)

func is_flammable(cell: Vector2i) -> bool:

	var tile_data = tile_map.get_cell_tile_data(cell)

	if tile_data == null:
		return false

	return tile_data.get_custom_data("flammable")


func get_burn_time(cell: Vector2i) -> float:

	var tile_data = tile_map.get_cell_tile_data(cell)

	if tile_data == null:
		return 0.0

	return tile_data.get_custom_data("burn_time")

func ignite_cell(cell: Vector2i) -> void:

	if not is_flammable(cell):
		return

	if burning_cells.has(cell):
		return

	var duration = get_burn_time(cell)

	if duration <= 0.0:
		return

	burning_cells[cell] = duration

	fire_started.emit(cell)

	if timer.is_stopped():
		timer.start()

func _on_timer_timeout() -> void:

	var next_burning: Dictionary = {}
	var new_ignitions: Dictionary = {}
	var finished_cells: Array[Vector2i] = []

	for cell in burning_cells:

		var remaining_time: float = burning_cells[cell]

		remaining_time -= tick_interval

		if remaining_time <= 0.0:
			finished_cells.append(cell)
		else:
			next_burning[cell] = remaining_time

		for direction in directions:

			var neighbor: Vector2i = cell + direction

			if burning_cells.has(neighbor):
				continue

			if new_ignitions.has(neighbor):
				continue

			if not is_flammable(neighbor):
				continue

			if randf() <= spread_chance:

				new_ignitions[neighbor] = get_burn_time(neighbor)

	burning_cells = next_burning

	for cell in new_ignitions:

		burning_cells[cell] = new_ignitions[cell]

		fire_started.emit(cell)

	for cell in finished_cells:

		burn_out_cell(cell)

	if burning_cells.is_empty():
		timer.stop()

func burn_out_cell(cell: Vector2i) -> void:

	tile_map.set_cell(
		cell,
		burnt_source_id,
		burnt_atlas_coords,
		burnt_alternative_tile
	)

	fire_finished.emit(cell)

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			var mouse_position = tile_map.get_local_mouse_position()

			var cell = tile_map.local_to_map(mouse_position)

			ignite_cell(cell)
