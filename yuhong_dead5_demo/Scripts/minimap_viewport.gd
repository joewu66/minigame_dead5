extends SubViewport

@export var camera_node : Node2D
@export var player_node : Node2D
@onready var players: Node = $"../../../../../Players"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_2d = get_tree().root.world_2d
	get_tree().root.set_canvas_cull_mask_bit(1,false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gamemanager.player:
		player_node = players.get_child(-1)
		camera_node.position = player_node.position
