extends Node3D

# 雾效果控制脚本

@export var fade_in_time = 2.0  # 雾效淡入时间
@export var max_density = 0.1  # 最大雾密度

@onready var environment = $WorldEnvironment.environment if has_node("WorldEnvironment") else null
@onready var fog_particles = $FogParticles if has_node("FogParticles") else null

var current_density = 0.0
var target_density = 0.0
var is_fading = false

func _ready():
	# 初始化为不可见
	visible = false
	
	# 如果有环境节点，确保雾初始化为0密度
	if environment:
		environment.fog_enabled = true
		environment.fog_density = 0.0
	
	# 如果有粒子系统，初始化为不发射
	if fog_particles:
		fog_particles.emitting = false

func _process(delta):
	# 如果正在淡入/淡出
	if is_fading and environment:
		# 计算新的密度
		current_density = move_toward(current_density, target_density, delta / fade_in_time * max_density)
		
		# 更新环境雾密度
		environment.fog_density = current_density
		
		# 如果达到目标密度，停止淡入/淡出
		if abs(current_density - target_density) < 0.001:
			is_fading = false

# 设置雾效果
func set_fog_active(active):
	visible = active
	
	if active:
		# 开始淡入
		target_density = max_density
		is_fading = true
		
		# 如果有粒子系统，开始发射
		if fog_particles:
			fog_particles.emitting = true
	else:
		# 开始淡出
		target_density = 0.0
		is_fading = true
		
		# 如果有粒子系统，停止发射
		if fog_particles:
			fog_particles.emitting = false
