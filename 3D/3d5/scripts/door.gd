extends Node3D

# 门的控制脚本
signal door_opened

# 门的状态
var is_open = false
var is_rotating = false
var timer_started = false

# 旋转速度和目标角度
@export var rotation_speed = 90.0  # 度/秒
@export var open_angle = 90.0  # 开门角度
@export var fog_delay = 5.0  # 开门后起雾的延迟时间(秒)

# 获取门的组件
@onready var door_mesh = $DoorMesh
@onready var door_collision = $DoorCollision
@onready var interaction_area = $InteractionArea
@onready var fog = $"../Fog"  # 假设雾在房间内

# 初始化
func _ready():
	# 确保雾初始不可见
	if fog:
		fog.visible = false
	
	# 连接交互区域的信号
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	print("门已初始化，交互区域已设置")
	
	# 添加调试信息
	if interaction_area:
		print("交互区域存在，大小：", interaction_area.get_child(0).shape.size if interaction_area.get_child_count() > 0 else "未知")
	else:
		print("警告：交互区域不存在")

# 处理输入和动画
func _process(delta):
	# 如果门正在旋转
	if is_rotating:
		# 计算旋转方向和目标角度
		var target_angle = deg_to_rad(open_angle) if is_open else 0.0
		var current_angle = door_mesh.rotation.y
		
		# 计算旋转步长
		var step = deg_to_rad(rotation_speed) * delta
		
		# 如果接近目标角度，直接设置为目标角度
		if abs(current_angle - target_angle) < step:
			door_mesh.rotation.y = target_angle
			door_collision.rotation.y = target_angle
			is_rotating = false
			
			# 如果门刚打开且计时器未启动，启动计时器
			if is_open and not timer_started:
				timer_started = true
				print("门已完全打开，开始计时")
				# 使用计时器延迟触发雾效果
				var timer = get_tree().create_timer(fog_delay)
				timer.timeout.connect(_on_fog_timer_timeout)
		else:
			# 否则继续旋转
			var direction = 1 if target_angle > current_angle else -1
			door_mesh.rotation.y += step * direction
			door_collision.rotation.y += step * direction

# 当玩家进入交互区域
func _on_interaction_area_body_entered(body):
	if body.is_in_group("player") or body.name == "Human" or body is Human:
		print("玩家进入门的交互区域")
		# 可以在这里显示提示UI

# 当玩家离开交互区域
func _on_interaction_area_body_exited(body):
	if body.is_in_group("player") or body.name == "Human" or body is Human:
		print("玩家离开门的交互区域")
		# 可以在这里隐藏提示UI

# 处理玩家输入
func _input(event):
	# 检查是否按下E键
	if event.is_action_pressed("interact"):  # 需要在项目设置中定义"interact"动作
		print("检测到交互键按下")
		# 检查是否有玩家在交互区域内
		var bodies = interaction_area.get_overlapping_bodies()
		print("交互区域内的物体数量：", bodies.size())
		
		for body in bodies:
			print("检查物体：", body.name, "，是否在player组：", body.is_in_group("player"), "，是否是Human：", body is Human)
			if body.is_in_group("player") or body.name == "Human" or body is Human:
				print("找到玩家，触发门的开关")
				toggle_door()
				break

# 切换门的状态
func toggle_door():
	if is_rotating:
		return
	
	is_open = !is_open
	is_rotating = true
	
	if is_open:
		print("开门")
		# 发出门已打开的信号
		door_opened.emit()
	else:
		print("关门")
		# 重置计时器状态
		timer_started = false
		# 如果关门，隐藏雾
		if fog:
			if fog.has_method("set_fog_active"):
				fog.set_fog_active(false)
			else:
				fog.visible = false

# 当雾效计时器超时
func _on_fog_timer_timeout():
	print("触发雾效果")
	if fog and is_open:
		if fog.has_method("set_fog_active"):
			fog.set_fog_active(true)
		else:
			fog.visible = true
