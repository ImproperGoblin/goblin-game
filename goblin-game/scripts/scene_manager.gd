extends Node

var room_container: Node
var player: CharacterBody2D
var player_camera: Camera2D

var current_room: Node = null
var is_transitioning := false

func _set_player(given_player: CharacterBody2D) -> void:
	self.player = given_player
	
func _set_player_camera(given_player_camera: Camera2D) -> void:
	self.player_camera = given_player_camera
	
func _set_room_container(given_room_container: Node) -> void:
	self.room_container = given_room_container

func _run_game() -> void:
	UIManager._show_gameplay_ui()
	_move_player_to_scene("res://scenes/levels/lush_level_1.tscn", 'SpawnA')
	
func _move_player_to_scene(target_room_path, target_spawn_name) -> void:
	UIManager._set_fade(1.0)
	
	if is_transitioning:
		return
	is_transitioning = true
	player.set_physics_process(false)
	
	if current_room:
		current_room.queue_free()
		await get_tree().process_frame
		
	var scene: PackedScene = load(target_room_path)
	var new_room := scene.instantiate()
	
	room_container.add_child(new_room)
	current_room = new_room
	
	player.hazard_tilemap = $"../Game/ActiveRoom/LevelRoot/TileMaps/LushHazardTileMap"
	player_camera.collision_shape_2d = $"../Game/ActiveRoom/LevelRoot/CameraLimiter/CollisionShape2D"
	
	var spawn: Marker2D = current_room._get_spawn_point(target_spawn_name)
	player.global_position = spawn.global_position
	player_camera.set_camera_limits()
	
	player.set_physics_process(true)
	
	await UIManager._fade(0.0)
	is_transitioning = false
