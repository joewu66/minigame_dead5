extends Node

@onready var human = $"../Players/Human"
@onready var ghost = $"../Players/Ghost"
@onready var ui = $"../UI/GameUI"
@onready var ghost_viewport_camera = get_node("/root/Main/GhostViewport/GhostCamera")
@onready var ghost_node = get_node("../Players/Ghost")
@onready var ghost_viewport = get_node("/root/Main/GhostViewport")
@onready var ghost_viewport_container = get_node("/root/Main/UI/GhostViewportContainer")

var game_time = 999999.0  # 无限时间
var game_active = true

signal game_over

func _ready():
	print("游戏管理器初始化...")
	print("网络状态 - 服务器: ", NetworkManager.is_server, " 已连接: ", NetworkManager.is_connected)
	
	# 检查节点引用
	print("人类节点: ", human)
	print("鬼魂节点: ", ghost)
	print("UI节点: ", ui)
	print("鬼魂摄像头: ", ghost_viewport_camera)
	print("鬼魂节点: ", ghost_node)
	print("鬼魂视口: ", ghost_viewport)
	print("鬼魂视口容器: ", ghost_viewport_container)
	
	# 连接背包更新信号
	if human:
		human.inventory_updated.connect(_on_inventory_updated)
	
	# 设置鬼魂视口容器
	if ghost_viewport and ghost_viewport_container:
		print("设置鬼魂视口容器...")
		
		# 确保GhostViewportContainer有正确的尺寸策略
		ghost_viewport_container.stretch = true
		ghost_viewport_container.stretch_shrink = 1  # 不缩小
		
		# 创建一个SubViewport子节点
		if ghost_viewport_container.get_child_count() == 0:
			print("创建SubViewport子节点...")
			var sub_viewport = SubViewport.new()
			sub_viewport.size = Vector2i(1920, 1080)  # 使用更高的分辨率
			sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			sub_viewport.transparent_bg = false  # 不使用透明背景
			sub_viewport.handle_input_locally = false  # 不在视口内处理输入
			ghost_viewport_container.add_child(sub_viewport)
		
		# 获取第一个子节点（应该是SubViewport）
		var viewport_child = ghost_viewport_container.get_child(0)
		if viewport_child is SubViewport:
			print("设置视口纹理...")
			
			# 检查鬼魂是否有自己的摄像头
			var ghost_own_camera = ghost.get_node_or_null("CameraPivot/Camera3D")
			if ghost_own_camera:
				print("使用鬼魂自带的摄像头")
				
				# 如果是鬼魂玩家，创建一个新的摄像头在视口中
				if NetworkManager.is_ghost_player():
					print("鬼魂玩家：创建视口专用摄像头")
					
					# 创建新摄像头
					var viewport_camera = Camera3D.new()
					viewport_camera.name = "GhostViewportCamera"
					viewport_child.add_child(viewport_camera)
					
					# 设置摄像头属性
					viewport_camera.current = true
					viewport_camera.global_transform = ghost_own_camera.global_transform
					
					# 设置世界
					viewport_child.world_3d = ghost_own_camera.get_world_3d()
					
					print("视口专用摄像头已创建并启用")
					
					# 在进程中持续更新摄像头位置
					ghost.set_meta("viewport_camera", viewport_camera)
				else:
					# 如果不是鬼魂玩家，只设置世界
					viewport_child.world_3d = ghost_own_camera.get_world_3d()
					print("设置视口世界为鬼魂摄像头世界")
			else:
				print("警告：鬼魂没有自带摄像头，使用备用方案")
				# 如果鬼魂没有自己的摄像头，使用原来的方法
				if ghost_viewport_camera and ghost_viewport_camera.get_parent():
					var old_parent = ghost_viewport_camera.get_parent()
					old_parent.remove_child(ghost_viewport_camera)
					viewport_child.add_child(ghost_viewport_camera)
					print("备用鬼魂摄像头已移动到子视口")
				else:
					print("警告：无法移动备用鬼魂摄像头")
	else:
		print("警告：无法设置鬼魂视口容器，节点引用无效")
	
	# 分配角色
	if NetworkManager.is_connected:
		NetworkManager.assign_roles()
		_initialize_players()
	
	human.human_caught.connect(_on_human_caught)
	ghost.human_caught.connect(_on_human_caught)
	human.item_used.connect(_on_item_used)
	
	start_game()

func _initialize_players():
	"""根据网络角色初始化玩家"""
	if NetworkManager.is_human_player():
		print("当前玩家是人类")
		# 启用人类控制，禁用鬼魂控制
		human.set_process_input(true)
		ghost.set_process_input(false)
		# 显示人类UI
		ui.show()
		
		# 隐藏鬼魂视口容器
		if ghost_viewport_container:
			ghost_viewport_container.visible = false
			print("隐藏鬼魂视口容器")
		
		# 确保人类摄像头是当前摄像头
		if human and human.get_node("CameraPivot/Camera3D"):
			human.get_node("CameraPivot/Camera3D").current = true
			print("人类摄像头已启用")
		
		# 禁用鬼魂自带摄像头
		var ghost_camera = ghost.get_node_or_null("CameraPivot/Camera3D")
		if ghost_camera:
			ghost_camera.current = false
	else:
		print("当前玩家是鬼魂")
		# 启用鬼魂控制，禁用人类控制
		human.set_process_input(false)
		ghost.set_process_input(true)
		
		# 隐藏人类UI
		ui.hide()
		
		# 设置鬼魂视口为全屏
		if ghost_viewport_container:
			ghost_viewport_container.visible = true
			ghost_viewport_container.anchor_left = 0  # 从左边缘开始
			ghost_viewport_container.anchor_right = 1  # 延伸到右边缘
			ghost_viewport_container.anchor_top = 0    # 从顶部边缘开始
			ghost_viewport_container.anchor_bottom = 1 # 延伸到底部边缘
			ghost_viewport_container.offset_left = 0
			ghost_viewport_container.offset_right = 0
			ghost_viewport_container.offset_top = 0
			ghost_viewport_container.offset_bottom = 0
			print("鬼魂视口容器设置为全屏")
		
		# 确保视口子节点的摄像头是当前摄像头
		if ghost_viewport_container and ghost_viewport_container.get_child_count() > 0:
			var viewport_child = ghost_viewport_container.get_child(0)
			if viewport_child is SubViewport:
				# 检查视口中是否有摄像头
				var cameras = []
				for child in viewport_child.get_children():
					if child is Camera3D:
						cameras.append(child)
						
				if cameras.size() > 0:
					print("视口中找到摄像头: ", cameras.size(), "个")
					cameras[0].current = true
					print("视口中的摄像头已设为当前")
				else:
					print("警告：视口中没有找到摄像头")
					
					# 如果没有找到摄像头，创建一个新的
					print("创建新的视口摄像头...")
					var viewport_camera = Camera3D.new()
					viewport_camera.name = "GhostViewportCamera"
					viewport_child.add_child(viewport_camera)
					
					# 设置摄像头属性
					viewport_camera.current = true
					
					# 获取鬼魂自带摄像头的变换
					var ghost_own_camera = ghost.get_node_or_null("CameraPivot/Camera3D")
					if ghost_own_camera:
						viewport_camera.global_transform = ghost_own_camera.global_transform
						
						# 设置世界
						viewport_child.world_3d = ghost_own_camera.get_world_3d()
					
					# 在进程中持续更新摄像头位置
					ghost.set_meta("viewport_camera", viewport_camera)
					print("新视口摄像头已创建并启用")
		else:
			print("警告：鬼魂视口容器未正确设置")
		
		# 确保人类摄像头不是当前摄像头
		if human and human.get_node("CameraPivot/Camera3D"):
			human.get_node("CameraPivot/Camera3D").current = false

func _process(_delta):
	if not game_active:
		return
	
	# 不再减少游戏时间
	if ui:
		ui.update_timer(game_time)
	
	# 更新视口摄像头位置
	if NetworkManager.is_ghost_player() and ghost_node:
		# 获取视口摄像头
		var viewport_camera = null
		if ghost_node.has_meta("viewport_camera"):
			viewport_camera = ghost_node.get_meta("viewport_camera")
		
		# 获取鬼魂自带摄像头
		var ghost_own_camera = ghost_node.get_node_or_null("CameraPivot/Camera3D")
		
		# 如果两者都存在，更新视口摄像头位置
		if viewport_camera and ghost_own_camera and viewport_camera.is_inside_tree():
			viewport_camera.global_transform = ghost_own_camera.global_transform
			
			# 调试信息（每5秒输出一次）
			if Engine.get_frames_drawn() % 300 == 0:
				print("视口摄像头位置已更新: ", viewport_camera.global_transform.origin)
				print("鬼魂节点位置: ", ghost_node.global_transform.origin)
		elif Engine.get_frames_drawn() % 300 == 0:  # 每5秒输出一次
			print("无法更新视口摄像头位置，视口摄像头: ", viewport_camera != null, " 鬼魂摄像头: ", ghost_own_camera != null)

func start_game():
	game_active = true
	if ui:
		ui.show_message("游戏开始！", 2.0)

func end_game(message: String):
	game_active = false
	if ui:
		ui.show_game_over(message)
	game_over.emit()

func _on_human_caught():
	end_game("鬼魂获胜！")

func _on_item_used():
	if ui:
		ui.update_item_count(human.slow_trap_count)

func _on_inventory_updated():
	if ui and ui.inventory_ui and NetworkManager.is_human_player():
		ui.inventory_ui.update_ui(human.inventory)
		# 高亮显示当前选中的槽位
		ui.inventory_ui.highlight_slot(human.selected_slot)

func restart_game():
	get_tree().reload_current_scene()
