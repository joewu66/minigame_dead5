extends CharacterBody3D
class_name Human

const Inventory = preload("res://scripts/inventory.gd")
const DefaultIcon = preload("res://scripts/default_icon.gd")

@export var speed = 5.0
@export var jump_velocity = 4.5
var mouse_sensitivity = 0.002

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var mesh = $MeshInstance3D
@onready var inventory_ui = $InventoryUI

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_alive = true
var slow_trap_count = 3

# 背包系统
var inventory = Inventory.new()
var selected_slot = 0

signal human_caught
signal item_used
signal inventory_updated

func _ready():
	# 将人类添加到player组，以便门能够识别
	add_to_group("player")
	print("人类已添加到player组")
	
	# 锁定鼠标到屏幕中心
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 检查是否为网络游戏
	if NetworkManager.is_connected:
		# 只有人类玩家才能控制
		set_process_input(NetworkManager.is_human_player())
		# 只有人类玩家才能看到摄像头
		if camera:
			camera.current = NetworkManager.is_human_player()
			
		# 连接网络同步信号
		NetworkManager.player_position_updated.connect(_on_player_position_updated)
		NetworkManager.trap_placed.connect(_on_trap_placed)
		
		print("人类：网络同步信号已连接")
		
	# 设置多人游戏权限
	set_multiplayer_authority(NetworkManager.human_player_id)
	
	# 初始化背包，初始物品个数为0
	# 不再添加初始的减速陷阱
	
	# 发出背包更新信号
	emit_signal("inventory_updated")
	
	# 直接更新背包UI
	if inventory_ui:
		print("初始化时直接更新背包UI")
		if inventory_ui.has_method("update_ui"):
			inventory_ui.update_ui(inventory)
			inventory_ui.highlight_slot(selected_slot)
		else:
			print("警告：背包UI没有update_ui方法")

func _input(event):
	if not is_alive:
		return
		
	# 鼠标视角控制
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)
	
	# 已删除使用道具的旧方式（按E释放减速陷阱）
	
	# 背包物品选择（数字键1-4）
	if event is InputEventKey and event.pressed:
		var key_code = event.keycode
		if key_code >= KEY_1 and key_code <= KEY_4:
			var slot_index = key_code - KEY_1
			if slot_index < Inventory.MAX_SLOTS:
				selected_slot = slot_index
				emit_signal("inventory_updated")
				
				# 使用该栏位的物品
				use_inventory_item(selected_slot)

func _physics_process(delta):
	if not is_alive:
		return
		
	# 只有人类玩家才能控制移动
	if NetworkManager.is_connected and not NetworkManager.is_human_player():
		return
		
	# 重力
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 移动
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	if input_dir != Vector2.ZERO:
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	# 同步位置（每10帧同步一次，减少网络流量）
	if NetworkManager.is_connected and NetworkManager.is_human_player() and Engine.get_frames_drawn() % 10 == 0:
		NetworkManager.send_position(global_position, Vector3(0, rotation.y, 0))

func use_slow_trap():
	# 优先使用背包中的减速陷阱
	var trap_used = false
	for i in range(Inventory.MAX_SLOTS):
		if inventory.items[i] != null and inventory.items[i].type == Inventory.ItemType.SLOW_TRAP:
			inventory.use_item(i)
			trap_used = true
			
			# 发出背包更新信号
			emit_signal("inventory_updated")
			
			# 直接更新背包UI
			if inventory_ui:
				print("使用物品后直接更新背包UI")
				if inventory_ui.has_method("update_ui"):
					inventory_ui.update_ui(inventory)
					inventory_ui.highlight_slot(selected_slot)
				else:
					print("警告：背包UI没有update_ui方法")
			
			break
	
	# 如果背包中没有，则使用旧系统的陷阱
	if not trap_used:
		if slow_trap_count <= 0:
			return
		slow_trap_count -= 1
	
	# 在玩家位置创建减速陷阱
	var slow_trap = preload("res://scenes/item.tscn").instantiate()
	get_parent().add_child(slow_trap)
	slow_trap.global_position = global_position
	
	# 同步陷阱位置
	if NetworkManager.is_connected:
		NetworkManager.send_trap_placed(global_position)
	
	item_used.emit()
	print("减速陷阱已使用")

# 使用背包中指定栏位的物品
func use_inventory_item(slot: int):
	var item_type = inventory.get_item_type(slot)
	if item_type == -1:
		return false
	
	match item_type:
		Inventory.ItemType.SLOW_TRAP:
			# 使用减速陷阱
			inventory.use_item(slot)
			
			# 在玩家位置创建减速陷阱
			var slow_trap = preload("res://scenes/item.tscn").instantiate()
			get_parent().add_child(slow_trap)
			slow_trap.global_position = global_position
			
			# 同步陷阱位置
			if NetworkManager.is_connected:
				NetworkManager.send_trap_placed(global_position)
			
			item_used.emit()
			
			# 发出背包更新信号
			emit_signal("inventory_updated")
			
			# 直接更新背包UI
			if inventory_ui:
				print("从背包使用物品后直接更新背包UI")
				if inventory_ui.has_method("update_ui"):
					inventory_ui.update_ui(inventory)
					inventory_ui.highlight_slot(selected_slot)
				else:
					print("警告：背包UI没有update_ui方法")
				
			print("从背包使用了减速陷阱")
			return true
		# 可以在这里添加更多物品类型的处理
	
	return false

# 添加物品到背包
func add_to_inventory(item_type: int, item_name: String, item_texture: Texture) -> bool:
	# 如果纹理为空，使用默认纹理
	if item_texture == null:
		print("警告：物品纹理为空，使用默认纹理")
		# 使用默认图标工具类
		item_texture = DefaultIcon.get_default_icon()
		print("加载默认纹理结果: ", item_texture)
	
	var success = inventory.add_item(item_type, item_name, item_texture)
	if success:
		print("添加物品到背包: ", item_name)
		
		# 发出背包更新信号
		emit_signal("inventory_updated")
		
		# 直接更新背包UI
		if inventory_ui:
			print("拾取物品后直接更新背包UI")
			if inventory_ui.has_method("update_ui"):
				inventory_ui.update_ui(inventory)
				inventory_ui.highlight_slot(selected_slot)
			else:
				print("警告：背包UI没有update_ui方法")
	return success
	
# 网络同步处理函数
func _on_player_position_updated(id: int, position: Vector3, rot: Vector3):
	# 只处理其他玩家的位置更新
	if id != NetworkManager.human_player_id or NetworkManager.is_human_player():
		return
		
	# 更新人类位置
	global_position = position
	rotation.y = rot.y
	
func _on_trap_placed(position: Vector3):
	# 如果是自己放置的陷阱，不需要再创建
	if NetworkManager.is_human_player():
		return
		
	# 创建陷阱
	var slow_trap = preload("res://scenes/item.tscn").instantiate()
	get_parent().add_child(slow_trap)
	slow_trap.global_position = position

func get_caught():
	is_alive = false
	human_caught.emit()
	print("人类被抓住了!")
	
	# 同步人类被抓住
	if NetworkManager.is_connected and NetworkManager.is_human_player():
		NetworkManager.send_player_caught()
