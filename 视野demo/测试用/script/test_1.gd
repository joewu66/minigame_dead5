extends Node2D

@onready var character_body_2d: CharacterBody2D = $CharacterBody2D
@onready var ground: TileMap = $ground
@onready var node_2d: Node2D = $Node2D



func _ready() -> void:
	var layer_name = ground.get_layer_name(2)
	ground.get_node(str(layer_name)).set_light_mask(2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	node_2d.global_position = character_body_2d.global_position
