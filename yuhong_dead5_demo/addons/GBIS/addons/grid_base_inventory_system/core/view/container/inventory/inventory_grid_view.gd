extends BaseGridView
## 格子视图，用于绘制格子
class_name InventoryGridView

## 输入控制
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(GBIS.input_click):
		if has_taken:
			if not GBIS.moving_item_service.moving_item:
				# 先清除物品信息
				GBIS.item_focus_service.item_lose_focus(_container_view.find_item_view_by_grid(grid_id))
				GBIS.moving_item_service.move_item_by_grid(_container_view.container_name, grid_id, offset, _size)
			elif GBIS.moving_item_service.moving_item is StackableData:
				GBIS.inventory_service.stack_moving_item(_container_view.container_name, grid_id)
			# 点击时，手动调用一次高亮
			_container_view.grid_hover(grid_id)
		else:
			GBIS.inventory_service.place_moving_item(_container_view.container_name, grid_id)
	if event.is_action_pressed(GBIS.input_quick_move):
		if has_taken:
			GBIS.item_focus_service.item_lose_focus(_container_view.find_item_view_by_grid(grid_id))
			GBIS.inventory_service.quick_move(_container_view.container_name, grid_id)
	if event.is_action_pressed(GBIS.input_use):
		if has_taken:
			GBIS.item_focus_service.item_lose_focus(_container_view.find_item_view_by_grid(grid_id))
			GBIS.inventory_service.use_item(_container_view.container_name, grid_id)
	if event.is_action_pressed(GBIS.input_split):
		if has_taken and not GBIS.moving_item_service.moving_item:
			GBIS.item_focus_service.item_lose_focus(_container_view.find_item_view_by_grid(grid_id))
			GBIS.inventory_service.split_item(_container_view.container_name, grid_id, offset, _size)
