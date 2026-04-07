extends Node

func _ready() -> void:
	SceneManager._set_player($Player)
	SceneManager._set_player_camera($PlayerCamera)
	SceneManager._set_room_container($ActiveRoom)
	
	SceneManager._run_game()
