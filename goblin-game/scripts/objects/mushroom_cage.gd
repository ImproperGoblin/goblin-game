extends Area2D

@export var persistent_id: String = 'progression.mushroom_cage_opened'

func _ready() -> void:
	if GameState._get_flag(persistent_id):
		self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if GameState._get_flag('item.mushroom_cage_key_taken'):
			GameState._set_flag(persistent_id, true)
			AudioManager._play_sound_effect('win')
			self.queue_free()
