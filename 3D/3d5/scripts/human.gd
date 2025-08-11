extends CharacterBody3D
class_name Human

@export var speed = 5.0
@export var jump_velocity = 4.5
var mouse_sensitivity = 0.002

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var mesh = $MeshInstance3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_alive = true
var slow_trap_count = 3

signal human_caught
signal item_used

func _ready():
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

func _input(event):
	if not is_alive:
		return
		
	# 鼠标视角控制
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/2)
	
	# 使用道具
	if event.is_action_pressed("use_item") and slow_trap_count > 0:
		use_slow_trap()

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
	print("减速陷阱剩余: ", slow_trap_count)
	
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
