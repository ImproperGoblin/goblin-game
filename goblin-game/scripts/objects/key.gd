extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameState._set_key_status()
		AudioManager._play_sound_effect('pickup')
		self.queue_free()
