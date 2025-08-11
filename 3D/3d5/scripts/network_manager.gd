extends Node

# 网络状态
var is_server: bool = false
var is_connected: bool = false
var player_id: int = 0

# 角色分配
var human_player_id: int = 0
var ghost_player_id: int = 1

# 玩家信息
var players = {}

# 同步状态
signal player_position_updated(player_id, position, rotation)
signal trap_placed(position)
signal ghost_attacked_sync(position)
signal player_caught()

func _ready():
	# 设置为自动加载
	print("NetworkManager初始化...")
	
	# 连接网络信号
	if multiplayer:
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		print("网络信号连接成功")
	else:
		print("警告：multiplayer不可用")

func _on_peer_connected(id):
	print("玩家连接：ID = ", id)
	players[id] = {"connected": true}
	
	# 如果我们是服务器，重新分配角色
	if is_server:
		assign_roles()
		
func _on_peer_disconnected(id):
	print("玩家断开连接：ID = ", id)
	if players.has(id):
		players.erase(id)
	
	# 如果我们是服务器，重新分配角色
	if is_server:
		assign_roles()

func assign_roles():
	"""分配角色：服务器玩家为人类，客户端玩家为鬼魂"""
	var my_id = multiplayer.get_unique_id()
	print("当前玩家ID: ", my_id)
	
	if is_server:
		# 服务器玩家为人类
		human_player_id = my_id
		# 鬼魂ID为连接的客户端ID，如果没有客户端连接，则为0
		var peers = multiplayer.get_peers()
		if peers.size() > 0:
			ghost_player_id = peers[0]
		else:
			ghost_player_id = 0
			print("警告：没有客户端连接，鬼魂ID设为0")
	else:
		# 客户端玩家为鬼魂
		ghost_player_id = my_id
		# 人类ID为服务器ID（通常为1）
		human_player_id = 1
	
	print("角色分配 - 人类ID: ", human_player_id, " 鬼魂ID: ", ghost_player_id)
	
	# 更新玩家信息
	players[human_player_id] = {"role": "human"}
	players[ghost_player_id] = {"role": "ghost"}
	
	print("玩家信息: ", players)

func is_human_player() -> bool:
	"""判断当前玩家是否为人类"""
	return multiplayer.get_unique_id() == human_player_id

func is_ghost_player() -> bool:
	"""判断当前玩家是否为鬼魂"""
	return multiplayer.get_unique_id() == ghost_player_id 

# 网络同步函数
@rpc("any_peer", "call_remote", "reliable")
func sync_player_position(player_id: int, position: Vector3, rotation: Vector3):
	# 发出信号，通知其他脚本更新玩家位置
	player_position_updated.emit(player_id, position, rotation)
	
@rpc("any_peer", "call_remote", "reliable")
func sync_trap_placed(position: Vector3):
	# 发出信号，通知其他脚本创建陷阱
	trap_placed.emit(position)
	
@rpc("any_peer", "call_remote", "reliable")
func sync_ghost_attack(position: Vector3):
	# 发出信号，通知其他脚本鬼魂攻击
	ghost_attacked_sync.emit(position)
	
@rpc("any_peer", "call_remote", "reliable")
func sync_player_caught():
	# 发出信号，通知其他脚本人类被抓住
	player_caught.emit()
	
# 发送同步信息的辅助函数
func send_position(position: Vector3, rotation: Vector3):
	var id = multiplayer.get_unique_id()
	rpc("sync_player_position", id, position, rotation)
	
func send_trap_placed(position: Vector3):
	rpc("sync_trap_placed", position)
	
func send_ghost_attack(position: Vector3):
	rpc("sync_ghost_attack", position)
	
func send_player_caught():
	rpc("sync_player_caught")
