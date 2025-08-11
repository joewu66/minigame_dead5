extends Resource
## 物品数据基类，不要直接继承这个类
class_name ItemData

@export_group("Common Settings")
## 物品名称，需要唯一
@export var item_name: String = "Item Name"
## 物品类型，值为“ANY”表示所有类型
@export var type: String = "ANY"
@export_group("Display Settings")
## 物品图标
@export var icon: Texture2D
## 物品占的列数
@export var columns: int = 1
## 物品占的行数
@export var rows: int = 1

## 获取货品形状
func get_shape() -> Vector2i:
	return Vector2i(columns, rows)

func can_drop() -> bool:
	push_warning("[Override this function] check if the item [%s] can drop" % item_name)
	return true

## 丢弃物品时调用，需重写
#func drop() -> void:
	#push_warning("[Override this function] item [%s] dropped" % item_name)

## 物品是否能出售（是否贵重物品等）
func can_sell() -> bool:
	push_warning("[Override this function] check if the item [%s] can be sell" % item_name)
	return true

## 物品是否能购买（检查资源是否足够等）
func can_buy() -> bool:
	push_warning("[Override this function] check if the item [%s] can be bought" % item_name)
	return true

## 购买后扣除资源
func cost() -> void:
	push_warning("[Override this function] [%s] cost resource" % item_name)

## 出售后增加资源
func sold() -> void:
	push_warning("[Override this function] [%s] add resource" % item_name)

## 购买并添加到背包
func buy() -> bool:
	if not can_buy():
		return false
	for target_inv in GBIS.current_inventories:
		if GBIS.inventory_service.add_item(target_inv, self):
			cost()
			return true
	return false
