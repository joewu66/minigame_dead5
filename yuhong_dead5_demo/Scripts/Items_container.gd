extends Node
#控制物品随机掉落

@onready var items_container: Node = $"."

var new_item: Item 
var new_item_data: Array[ItemData] = [null,null,null,null,null,null]


static var random_list: Array[ItemData] = [
	preload("res://Resources/test_item_1.tres"),
	preload("res://Resources/test_item_2.tres"),
	preload("res://Resources/test_item_3.tres")
]

func _ready() -> void:
	item_randomly_generated()

#随机生成道具的方法
func item_randomly_generated():
	for i in range(6):
		#实例化new_item
		new_item = preload("res://Scenes/item.tscn").instantiate()
		items_container.add_child(new_item)
		
		#决定生成的道具种类和sprite
		new_item_data[i] = random_list.pick_random()
		var sprite = new_item_data[i].drop_model.instantiate()
		new_item.sprite.add_child(sprite)
		
		#决定随机生成的道具位置
		var random_position = Vector2(randf_range(0,1000),randf_range(0,1000))
		new_item.position = random_position
		
		new_item.data = new_item_data[i]
