extends Node2D

const SNAP_TIME: float = 2.0

var player_node: Node = null
var increase_snap_timer: bool = false
var snap_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if increase_snap_timer:
		snap_timer += delta
		
	if player_node and snap_timer > SNAP_TIME:
		player_node._reset_to_safe_pos()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		snap_timer = 0
		increase_snap_timer = true
		player_node = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		snap_timer = 0
		increase_snap_timer = false
		player_node = null
