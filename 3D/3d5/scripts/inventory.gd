extends Node

class_name Inventory

const DefaultIcon = preload("res://scripts/default_icon.gd")

# 背包最大容量
const MAX_SLOTS = 4

# 背包物品数组
var items = []

# 背包物品类型枚举
enum ItemType {
	SLOW_TRAP = 0,
	# 可以在这里添加更多物品类型
}

# 物品数据结构
class InventoryItem:
	var type: int
	var name: String
	var icon: Texture
	var count: int = 1
	
	func _init(item_type: int, item_name: String, item_icon: Texture):
		type = item_type
		name = item_name
		icon = item_icon
		
		# 如果图标为空，使用默认图标
		if icon == null:
			print("警告：InventoryItem创建时图标为空，使用默认图标")
			icon = DefaultIcon.get_default_icon()
			print("加载默认图标结果: ", icon)

# 初始化背包
func _init():
	# 初始化背包为空
	items.resize(MAX_SLOTS)
	for i in range(MAX_SLOTS):
		items[i] = null

# 添加物品到背包
func add_item(item_type: int, item_name: String, item_icon: Texture) -> bool:
	# 检查是否已有相同类型的物品
	for i in range(MAX_SLOTS):
		if items[i] != null and items[i].type == item_type:
			items[i].count += 1
			return true
	
	# 如果没有相同类型的物品，找一个空位
	for i in range(MAX_SLOTS):
		if items[i] == null:
			items[i] = InventoryItem.new(item_type, item_name, item_icon)
			return true
	
	# 背包已满
	return false

# 获取物品数量
func get_item_count(item_type: int) -> int:
	var count = 0
	for i in range(MAX_SLOTS):
		if items[i] != null and items[i].type == item_type:
			count += items[i].count
	return count

# 使用指定栏位的物品
func use_item(slot: int) -> int:
	if slot < 0 or slot >= MAX_SLOTS or items[slot] == null:
		return -1
	
	var item_type = items[slot].type
	items[slot].count -= 1
	
	# 如果物品数量为0，移除该物品
	if items[slot].count <= 0:
		items[slot] = null
	
	return item_type

# 获取指定栏位的物品类型
func get_item_type(slot: int) -> int:
	if slot < 0 or slot >= MAX_SLOTS or items[slot] == null:
		return -1
	
	return items[slot].type
