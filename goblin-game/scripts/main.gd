extends Node2D

@onready var fade: ColorRect = $HUD/Fade

var level: int = 1
var current_level_root: Node = null
var level_root: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up Level
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")
	await _load_level(level)

# -----------------
# LEVEL MANAGEMENT
# -----------------

func _load_level(level_number:int, exit_name: String = "") -> void:
	
	if current_level_root:
		current_level_root.queue_free()

	# Change level
	var level_path = "res://scenes/levels/lush_level_%s.tscn" %level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root, exit_name)
	
	await _fade(0.0)
	
func _setup_level(level_root: Node, exit_name: String = "") -> void:
	
	# Connect EXIT
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	if exit_name != "":
		var tunnel_exit = level_root.get_node_or_null("TunnelExits/" + exit_name)
		if tunnel_exit:
			var player = level_root.get_node("Player")
			player.position = tunnel_exit.global_position
			
	var tunnel_entrances = level_root.get_node_or_null("TunnelEntrances")
	if !tunnel_entrances or tunnel_entrances.get_child_count() == 0:
		return
	
	for entrance in tunnel_entrances.get_children():
		entrance.body_entered.connect(_on_tunnel_body_entered.bind(entrance))

# -----------------
# SIGNAL HANDLERS
# -----------------
func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		level += 1
		body.can_move = false
		await _fade(1.0)
		call_deferred("_load_level",(level))

func _on_tunnel_body_entered(body: Node2D, entrance: Node2D) -> void:
	if body.name == "Player":
		var level_id = entrance.get_meta("level_id")
		var exit_name = entrance.get_meta("exit_name")
		
		if !level_id or !exit_name:
			return
			
		level = level_id
		body.can_move = false
		await _fade(1.0)
		call_deferred("_load_level", (level), exit_name)
# -----------------
# VISUALS
# -----------------
func _fade(to_alpha: float) -> void:
	var fade_tween := create_tween()
	fade_tween.tween_property(fade, "modulate:a", to_alpha, 1.2)
	await fade_tween.finished
