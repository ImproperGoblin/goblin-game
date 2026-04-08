extends Node2D


func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	# Check if he is freed
	if GameState._get_flag('progression.mushroom_cage_opened'):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "celebrate"
		$AnimatedSprite2D.play()
