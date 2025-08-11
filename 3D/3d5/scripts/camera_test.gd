extends Node

# 摄像头测试脚本
func _ready():
	print("=== 摄像头测试开始 ===")
	
	# 等待一帧确保所有节点都加载完成
	await get_tree().process_frame
	
	# 检查GhostViewport
	var ghost_viewport = get_node("/root/Main/GhostViewport")
	if ghost_viewport:
		print("GhostViewport 找到: ", ghost_viewport)
		print("GhostViewport size: ", ghost_viewport.size)
		print("GhostViewport render_target_update_mode: ", ghost_viewport.render_target_update_mode)
	else:
		print("GhostViewport 未找到")
	
	# 检查GhostCamera
	var ghost_camera = get_node("/root/Main/GhostViewport/GhostCamera")
	if ghost_camera:
		print("GhostCamera 找到: ", ghost_camera)
		print("GhostCamera current: ", ghost_camera.current)
		print("GhostCamera transform: ", ghost_camera.global_transform)
	else:
		print("GhostCamera 未找到")
	
	# 检查GhostViewportContainer
	var ghost_viewport_container = get_node("/root/Main/UI/GhostViewportContainer")
	if ghost_viewport_container:
		print("GhostViewportContainer 找到: ", ghost_viewport_container)
		print("GhostViewportContainer viewport: ", ghost_viewport_container.get_child(0) if ghost_viewport_container.get_child_count() > 0 else "无子视口")
	else:
		print("GhostViewportContainer 未找到")
	
	print("=== 摄像头测试完成 ===") 
