extends Area2D
class_name RoomExit

@export_file("*.tscn") var target_room_path: String
@export var target_spawn_name: String

var busy := false

func _on_body_entered(body: Node) -> void:
	if body.name == 'Player':
		if busy:
			return

		busy = true
		await SceneManager._move_player_to_scene(target_room_path, target_spawn_name)
		busy = false
