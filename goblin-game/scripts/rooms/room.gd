extends Node2D
class_name Room

func _get_spawn_point(spawn_name: String) -> Marker2D:
	var spawns := $Spawns
	if spawns.has_node(spawn_name):
		return spawns.get_node(spawn_name)
	return null
