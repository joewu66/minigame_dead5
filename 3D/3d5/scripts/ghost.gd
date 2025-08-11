extends CharacterBody3D
class_name Ghost

@export var speed = 6.0
@export var attack_range = 2.0
@export var attack_cooldown = 1.0
var mouse_sensitivity = 0.002

@onready var mesh = $MeshInstance3D
@onready var attack_area = $AttackArea
@onready var camera_pivot = $CameraPivot if has_node("CameraPivot") else null

var can_attack = true
var is_slowed = false
var normal_speed
var slow_factor = 0.3

signal ghost_attacked
signal human_caught

func _ready():
	normal_speed = speed
	attack_area.body_entered.connect(_on_attack_area_entered)
	
	print("鬼魂初始化 - 是鬼魂玩家: ", NetworkManager.is_ghost_player())
	
	# 锁定鼠标到屏幕中心（仅当是鬼魂玩家时）
	if NetworkManager.is_connected and NetworkManager.is_ghost_player():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# 确保摄像头设置正确
		if camera_pivot and camera_pivot.has_node("Camera3D"):
			var camera = camera_pivot.get_node("Camera3D")
			camera.current = true
			print("鬼魂：摄像头已设为当前，位置: ", camera.global_position)
			
			# 直接将摄像头连接到主视口
			var main_viewport = get_viewport()
			if main_viewport:
				print("鬼魂：主视口找到，设置世界")
				# 不要移动摄像头，只设置为当前
				camera.current = true
	
	# 检查是否为网络游戏
	if NetworkManager.is_connected:
		# 只有鬼魂玩家才能控制
		set_process_input(NetworkManager.is_ghost_player())
		
		# 连接网络同步信号
		NetworkManager.player_position_updated.connect(_on_player_position_updated)
		NetworkManager.ghost_attacked_sync.connect(_on_ghost_attacked_sync)
		NetworkManager.player_caught.connect(_on_player_caught_sync)
		
		print("鬼魂：网络同步信号已连接")
		
	# 设置多人游戏权限
	set_multiplayer_authority(NetworkManager.ghost_player_id)
		
	# 调试信息
	print("鬼魂初始化完成，摄像头状态: ", camera_pivot != null)
	
	# 延迟一帧再次检查摄像头
	await get_tree().process_frame
	if NetworkManager.is_ghost_player() and camera_pivot and camera_pivot.has_node("Camera3D"):
		var camera = camera_pivot.get_node("Camera3D")
		print("鬼魂：延迟检查 - 摄像头当前状态: ", camera.current)
		camera.current = true

func _input(event):
	# 攻击
	if event.is_action_pressed("ghost_attack") and can_attack:
		attack()
		
	# 鼠标视角控制
	if camera_pivot and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	# 只有鬼魂玩家才能控制移动
	if NetworkManager.is_connected and not NetworkManager.is_ghost_player():
		return
		
	# 移动控制 (WASD键)
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):  # 改为与人类相同的按键
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
	if NetworkManager.is_connected and NetworkManager.is_ghost_player() and Engine.get_frames_drawn() % 10 == 0:
		NetworkManager.send_position(global_position, Vector3(0, rotation.y, 0))

func attack():
	can_attack = false
	ghost_attacked.emit()
	
	# 检查攻击范围内的人类
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body is Human:
			body.get_caught()
			human_caught.emit()
			
			# 同步人类被抓住
			if NetworkManager.is_connected:
				NetworkManager.send_player_caught()
			break
	
	# 同步攻击
	if NetworkManager.is_connected:
		NetworkManager.send_ghost_attack(global_position)
	
	# 攻击冷却
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
# 网络同步处理函数
func _on_player_position_updated(id: int, position: Vector3, rot: Vector3):
	# 只处理其他玩家的位置更新
	if id != NetworkManager.ghost_player_id or NetworkManager.is_ghost_player():
		return
		
	# 更新鬼魂位置
	global_position = position
	rotation.y = rot.y
	
func _on_ghost_attacked_sync(position: Vector3):
	# 如果是自己攻击的，不需要处理
	if NetworkManager.is_ghost_player():
		return
		
	# 播放攻击动画或效果
	ghost_attacked.emit()
	
func _on_player_caught_sync():
	# 如果是自己抓住的，不需要处理
	if NetworkManager.is_ghost_player():
		return
		
	# 播放人类被抓住的效果
	human_caught.emit()

func apply_slow_effect(duration: float):
	if is_slowed:
		return
	
	is_slowed = true
	speed = normal_speed * slow_factor
	print("鬼魂被减速!")
	
	await get_tree().create_timer(duration).timeout
	
	speed = normal_speed
	is_slowed = false
	print("鬼魂恢复正常速度")

func _on_attack_area_entered(body):
	if body is Human and can_attack:
		# 自动攻击进入范围的人类
		pass
