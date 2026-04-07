extends Area2D

func _ready() -> void:
	$"../Label".visible_ratio = 0
	
func _display_dialogue() -> void:
	var dialogue_tween := create_tween()
	dialogue_tween.tween_property($"../Label", "visible_ratio", 1, 1.5)
	await dialogue_tween.finished

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_display_dialogue()
