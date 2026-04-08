extends Area2D

@export var persistent_id: String = 'item.mushroom_cage_key_taken'

func _ready() -> void:
	if GameState._get_flag(persistent_id):
		self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameState._set_flag(persistent_id, true)
		AudioManager._play_sound_effect('pickup')
		self.queue_free()
