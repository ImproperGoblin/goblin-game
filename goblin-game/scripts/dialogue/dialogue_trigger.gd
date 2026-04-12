extends Area2D

var dialogue_enabled: bool = true

func _ready() -> void:
	$"../Label".visible_ratio = 0
	
func _display_dialogue() -> void:
	var dialogue_tween := create_tween()
	dialogue_tween.tween_property($"../Label", "visible_ratio", 1, 1.5)
	await dialogue_tween.finished

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and dialogue_enabled:
		_display_dialogue()

func _disable_dialogue() -> void:
	dialogue_enabled = false
