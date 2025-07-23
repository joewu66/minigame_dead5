extends Node
## 容器业务类
class_name BaseContainerService

## 容器数据库引用
var _container_repository: ContainerRepository = ContainerRepository.instance

## 保存所有容器
func save() -> void:
	_container_repository.save()

## 读取所有容器
func load() -> void:
	_container_repository.load()

## 注册容器，如果重名，则返回已存在的容器
func regist(container_name: String, columns: int, rows: int, avilable_types: Array[String] = ["ANY"]) -> ContainerData:
	return _container_repository.add_container(container_name, columns, rows, avilable_types)

## 获取容器数据
func get_container(container_name: String) -> ContainerData:
	return _container_repository.get_container(container_name)

## 通过物品名称找所有物品（同名物品可能有多个实例）
func find_item_data_by_item_name(container_name: String, item_name: String) -> Array[ItemData]:
	var inv = _container_repository.get_container(container_name)
	if inv:
		return inv.find_item_data_by_item_name(item_name)
	return []

## 通过格子找物品
func find_item_data_by_grid(container_name: String, grid_id: Vector2i) -> ItemData:
	return _container_repository.get_container(container_name).find_item_data_by_grid(grid_id)

## 判断容器是否存在
func is_container_existed(container_name: String) -> bool:
	return _container_repository.get_container(container_name) != null

## 尝试把物品放置到指定格子
func place_to(container_name: String, item_data: ItemData, grid_id: Vector2i) -> bool:
	if item_data:
		var inv = _container_repository.get_container(container_name)
		if inv:
			var grids = inv.try_add_to_grid(item_data, grid_id - GBIS.moving_item_service.moving_item_offset)
			if grids:
				GBIS.sig_inv_item_added.emit(container_name, item_data, grids)
				return true
	return false
