extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/levels/MainGameLevel.tscn"
	)


func _on_quit_button_pressed() -> void:
	$QuitConfirmDialog.popup_centered()


func _on_quit_confirm_dialog_confirmed() -> void:
	get_tree().quit()
