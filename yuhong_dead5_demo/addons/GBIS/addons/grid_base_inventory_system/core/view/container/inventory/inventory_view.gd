@tool
extends BaseContainerView
## 背包视图，控制背包的绘制
class_name InventoryView

## 允许存放的物品类型，如果背包名字重复，可存放的物品类型需要一样
@export var avilable_types: Array[String] = ["ANY"]

## 格子高亮
func grid_hover(grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	
	var moving_item_view = GBIS.moving_item_service.moving_item_view
	moving_item_view.base_size = base_size
	moving_item_view.stack_num_color = stack_num_color
	moving_item_view.stack_num_font = stack_num_font
	moving_item_view.stack_num_font_size = stack_num_font_size
	moving_item_view.stack_num_margin = stack_num_margin
	
	var moving_item_offset = GBIS.moving_item_service.moving_item_offset
	var moving_item = GBIS.moving_item_service.moving_item
	var item_shape = moving_item.get_shape()
	var grids = _get_grids_by_shape(grid_id - moving_item_offset, item_shape)
	var has_conflict = item_shape.x * item_shape.y != grids.size() or not GBIS.inventory_service.get_container(container_name).is_item_avilable(moving_item)
	for grid in grids:
		if has_conflict:
			break 
		has_conflict = _grid_map[grid].has_taken
		var item_view = _grid_item_map.get(grid_id)
		if has_conflict and item_view:
			var item_data: ItemData = item_view.data
			if item_data is StackableData:
				if item_data.item_name == GBIS.moving_item_service.moving_item.item_name and not item_data.is_full():
					has_conflict = false
	for grid in grids:
		var grid_view = _grid_map[grid]
		grid_view.state = BaseGridView.State.CONFLICT if has_conflict else BaseGridView.State.AVILABLE

## 格子失去高亮
func grid_lose_hover(grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	
	var moving_item_offset = GBIS.moving_item_service.moving_item_offset
	var moving_item = GBIS.moving_item_service.moving_item
	var item_shape = moving_item.get_shape()
	var grids = _get_grids_by_shape(grid_id - moving_item_offset, item_shape)
	for grid in grids:
		var grid_view = _grid_map[grid]
		grid_view.state = BaseGridView.State.TAKEN if grid_view.has_taken else BaseGridView.State.EMPTY

## 通过格子ID获取物品视图
func find_item_view_by_grid(grid_id: Vector2i) -> ItemView:
	return _grid_item_map.get(grid_id)

## 初始化
func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not container_name:
		push_error("Inventory must have a name.")
		return
	
	var ret = GBIS.inventory_service.regist(container_name, container_columns, container_rows, avilable_types)
	
	# 使用已注册的信息覆盖View设置
	avilable_types = ret.avilable_types
	container_columns = ret.columns
	container_rows = ret.rows
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	_init_grid_container()
	_init_item_container()
	_init_grids()
	GBIS.sig_inv_item_added.connect(_on_item_added)
	GBIS.sig_inv_item_removed.connect(_on_item_removed)
	GBIS.sig_inv_item_updated.connect(_on_inv_item_updated)
	GBIS.sig_inv_refresh.connect(refresh)
	
	visibility_changed.connect(_on_visible_changed)
	
	if not stack_num_font:
		stack_num_font = get_theme_font("font")
	
	call_deferred("refresh")

## 监听添加物品
func _on_item_added(inv_name:String, item_data: ItemData, grids: Array[Vector2i]) -> void:
	if not inv_name == container_name:
		return
	if not is_visible_in_tree():
		return
	
	var item = _draw_item(item_data, grids[0])
	_items.append(item)
	_item_grids_map[item] = grids
	for grid in grids:
		_grid_map[grid].taken(grid - grids[0])
		_grid_item_map[grid] = item

## 监听移除物品
func _on_item_removed(inv_name:String, item_data: ItemData) -> void:
	if not inv_name == container_name:
		return
	if not is_visible_in_tree():
		return
	
	for i in range(_items.size() - 1, -1, -1):
		var item = _items[i]
		if item.data == item_data:
			var grids = _item_grids_map[item]
			for grid in grids:
				_grid_map[grid].release()
				_grid_item_map[grid] = null
			item.queue_free()
			_items.remove_at(i)
			break

## 监听更新物品
func _on_inv_item_updated(inv_name: String, grid_id: Vector2i) -> void:
	if not inv_name == container_name:
		return
	if not is_visible_in_tree():
		return
	
	_grid_item_map[grid_id].queue_redraw()

## 绘制物品
func _draw_item(item_data: ItemData, first_grid: Vector2i) -> ItemView:
	var item = ItemView.new(item_data, base_size, stack_num_font, stack_num_font_size, stack_num_margin, stack_num_color)
	_item_container.add_child(item)
	item.global_position = _grid_map[first_grid].global_position
	return item

## 初始化格子View
func _init_grids() -> void:
	for row in container_rows:
		for col in container_columns:
			var grid_id = Vector2i(col, row)
			var grid = InventoryGridView.new(self, grid_id, base_size, grid_border_size, grid_border_color, 
				gird_background_color_empty, gird_background_color_taken, gird_background_color_conflict, grid_background_color_avilable)
			_grid_container.add_child(grid)
			_grid_map[grid_id] = grid
