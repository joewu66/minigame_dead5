extends ConsumableData
##伤害类道具类
class_name DamageItem

@export var drop_model: PackedScene

## 物品被使用时调用
func use() -> bool:
	if current_amount > 0:
		var consumed_amount = consume()
		if consumed_amount > 0:
			current_amount -= consumed_amount
			if current_amount <= 0:
				return destroy_if_empty
	return false

## 消耗方法，需重写，返回消耗数量（>=0）
func consume() -> int:
	push_warning("[Override this function] consumable item [%s] has been consumed" % item_name)
	print("item_used")
	return 1
	
func drop() -> void:
	print("drop()called")
	gamemanager.player.throw_item(self)
