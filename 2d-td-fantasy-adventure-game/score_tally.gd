extends Node

var total_score: int = 0

@onready var score_label: Label = $ScoreLabel

func add_score(amount: int) -> void:
	total_score += amount
	score_label.text = "Score: " + str(total_score)
