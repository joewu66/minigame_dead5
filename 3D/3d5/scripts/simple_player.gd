extends CharacterBody3D

# 简单的玩家控制脚本，用于测试门的交互

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

@onready var camera = $Camera3D

# 重力
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# 将玩家添加到"player"组，以便门能够识别
	add_to_group("player")
	
	# 捕获鼠标
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# 添加重力
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 处理跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 获取输入方向
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# 处理移动
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

# 处理鼠标输入来旋转相机
func _input(event):
	# 如果按下ESC，释放鼠标
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# 处理鼠标移动
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# 水平旋转整个玩家
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# 垂直旋转只旋转相机
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# 限制相机的垂直旋转
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)