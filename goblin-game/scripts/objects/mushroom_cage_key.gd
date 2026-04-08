extends Area2D

const CAGE_KEY_FLAG := 'item.mushroom_cage_key_taken'

func _ready() -> void:
	if WorldState.is_true(CAGE_KEY_FLAG):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		WorldState.set_flag(CAGE_KEY_FLAG, true)
		AudioManager._play_sound_effect('pickup')
		queue_free()
