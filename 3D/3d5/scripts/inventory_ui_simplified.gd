extends Control

# 背包UI控制脚本
const Inventory = preload("res://scripts/inventory.gd")
const DefaultIcon = preload("res://scripts/default_icon.gd")

@onready var slot_container = $SlotContainer
var inventory_slots = []

# 初始化背包UI
func _ready():
	print("背包UI初始化")
	
	# 检查slot_container是否存在
	if not slot_container:
		print("错误：slot_container不存在")
		return
		
	print("slot_container存在，开始获取槽位")
	
	# 获取所有物品槽
	for i in range(Inventory.MAX_SLOTS):
		var slot = slot_container.get_node("Slot" + str(i + 1))
		if slot:
			print("找到槽位:", i+1)
			inventory_slots.append(slot)
			# 添加数字标签
			var number_label = Label.new()
			number_label.text = str(i + 1)
			number_label.position = Vector2(5, 5)
			number_label.add_theme_color_override("font_color", Color.WHITE)
			number_label.add_theme_color_override("font_outline_color", Color.BLACK)
			number_label.add_theme_constant_override("outline_size", 1)
			slot.add_child(number_label)
		else:
			print("警告：未找到槽位:", i+1)
			
	print("背包UI初始化完成，共找到", inventory_slots.size(), "个槽位")

# 创建物品图标 - 简化版本
func create_item_icon(slot: Panel) -> TextureRect:
	print("创建新的物品图标")
	var icon = TextureRect.new()
	icon.name = "ItemIcon"
	
	# 使用简单的拉伸模式
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# 简单设置位置和大小
	var padding = 5
	var size = slot.size - Vector2(padding * 2, padding * 2)
	icon.position = Vector2(padding, padding)
	icon.size = size
	
	slot.add_child(icon)
	return icon

# 创建数量标签 - 简化版本
func create_count_label(slot: Panel) -> Label:
	var count_label = Label.new()
	count_label.name = "CountLabel"
	
	# 简单设置位置
	count_label.position = Vector2(slot.size.x - 15, slot.size.y - 15)
	
	# 设置对齐方式
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	
	# 添加轮廓使其更容易看到
	count_label.add_theme_color_override("font_color", Color.WHITE)
	count_label.add_theme_color_override("font_outline_color", Color.BLACK)
	count_label.add_theme_constant_override("outline_size", 2)
	
	slot.add_child(count_label)
	return count_label

# 更新背包UI显示
func update_ui(inventory):
	print("更新背包UI，槽位数量: ", inventory_slots.size())
	print("背包物品: ", inventory.items)
	
	for i in range(min(inventory_slots.size(), Inventory.MAX_SLOTS)):
		var slot = inventory_slots[i]
		var item = inventory.items[i]
		
		print("槽位 ", i, " 物品: ", item)
		
		# 获取物品图标和数量标签
		var icon = slot.get_node_or_null("ItemIcon")
		var count_label = slot.get_node_or_null("CountLabel")
		
		if item != null:
			# 创建或更新物品图标
			if not icon:
				icon = create_item_icon(slot)
			
			print("设置图标纹理: ", item.icon)
			icon.texture = item.icon
			
			# 调试信息：检查纹理是否有效
			if icon.texture == null:
				print("警告：图标纹理为空")
				# 使用默认图标工具类
				icon.texture = DefaultIcon.get_default_icon()
				print("加载默认纹理结果: ", icon.texture)
			
			# 创建或更新数量标签
			if not count_label:
				count_label = create_count_label(slot)
			
			# 只有数量大于1时才显示数量
			if item.count > 1:
				count_label.text = str(item.count)
				count_label.show()
			else:
				count_label.hide()
				
			icon.show()
		else:
			# 如果没有物品，隐藏图标和数量
			if icon:
				icon.hide()
			if count_label:
				count_label.hide()

# 高亮显示选中的槽位
func highlight_slot(slot_index: int):
	for i in range(inventory_slots.size()):
		var slot = inventory_slots[i]
		if i == slot_index:
			slot.modulate = Color(1.5, 1.5, 1.5, 1.0)  # 高亮
		else:
			slot.modulate = Color(1.0, 1.0, 1.0, 1.0)  # 正常
