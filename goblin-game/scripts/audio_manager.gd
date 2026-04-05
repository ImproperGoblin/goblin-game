extends Node2D

var effects := {
	'hit': preload("res://assets/audio/effects/hit.wav"),
	'death': preload("res://assets/audio/effects/death.wav"),
	'pickup': preload("res://assets/audio/effects/pickup.wav"),
	'win': preload("res://assets/audio/effects/victory.wav"),
}

func _play_sound_effect(sound: String) -> void:
	if not effects.has(sound):
		return
	
	var player := AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = effects[sound]
	player.bus = 'SFX'
	
	player.finished.connect(player.queue_free)
	player.play()
