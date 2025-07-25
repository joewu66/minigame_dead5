extends Area2D
class_name Item

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $sprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var data: ItemData
static var scene: PackedScene = preload("res://Scenes/item.tscn")

func _ready() -> void:
	label.visible = false
	
func _process(delta: float) -> void:
	#按键拾取道具
	if label.visible and Input.is_action_just_pressed("pick_up"):
		#var item_picked_up = load("res://Resources/test_item.tres") 
		GBIS.add_item(gamemanager.player_1_inv_name, data) 
		queue_free()
		
func _on_body_entered(body: Node2D) -> void:
	#靠近显示label
	label.visible = true

func _on_body_exited(body: Node2D) -> void:
	#远离label消失
	label.visible = false
	
#物品的掉落方法（好像有问题，每次扔东西都会捡到一个新的resource资源，是因为实例化？）
static func drop_item(position: Vector2, item_data: ItemData = null) -> Item:
	var item_to_drop: Item = scene.instantiate()
	item_to_drop.position = position
	if item_data:
		item_to_drop.data = item_data
	return item_to_drop
