extends Node

const MAX_PLAYER_HP: int = 6

var player_hp: int = MAX_PLAYER_HP

func _ready() -> void:
	pass # Replace with function body.

func _reset_game_state():
	player_hp = MAX_PLAYER_HP
