extends ProgressBar



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame 

	var player = get_tree().get_first_node_in_group("player")
	var max = max_value
	if player:
		max_value = player.max_health
		value = player.health
		player.healthChanged.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: float, new_max_health: float) -> void:
	max_value = new_max_health
	value = new_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
