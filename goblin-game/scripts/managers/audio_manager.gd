extends Node

@onready var effects := {
	'death': $SFX/DeathSFX,
	'hit': $SFX/HitSFX,
	'pickup': $SFX/PickupSFX,
	'win': $SFX/VictorySFX,
}

func _play_sound_effect(sound: String) -> void:
	if not effects.has(sound):
		return

	effects[sound].play()
