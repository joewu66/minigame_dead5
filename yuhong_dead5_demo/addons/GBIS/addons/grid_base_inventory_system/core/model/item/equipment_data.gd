extends ItemData
## 装备数据基类，你的装备数据类应该继承此类
class_name EquipmentData

## 检测装备是否可用，需重写
func test_need(slot_name: String) -> bool:
	push_warning("[Override this function] [%s]:[%s] Equipment slot test passed. 
		If you have multiple players, you should test whether this slot belongs to GBIS.current_player. 
		Don't forget to change GBIS.current_player to the player that is currently being modified." % [GBIS.current_player, slot_name])
	return true

## 装备时调用，需重写；也可以使用 GBIS.sig_slot_item_equipped 信号行处理
func equipped(slot_name: String) -> void:
	push_warning("[Override this function] [%s] equipped item [%s] at slot [%s]" % [GBIS.current_player, item_name, slot_name])

## 脱装备时调用，需重写；也可以用 GBIS.sig_slot_item_unequipped 信号进行处理
func unequipped(slot_name: String) -> void:
	push_warning("[Override this function] [%s] unequipped item [%s] at slot [%s]" % [GBIS.current_player, item_name, slot_name])
