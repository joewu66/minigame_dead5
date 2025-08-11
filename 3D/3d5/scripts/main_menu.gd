extends Control

@onready var create_button = $VBoxContainer/CreateButton
@onready var join_button = $VBoxContainer/JoinButton
@onready var status_label = $StatusLabel

var peer = ENetMultiplayerPeer.new()
var server_ip = "127.0.0.1" # 本地测试用，连接远程服务器时需要修改为实际IP
var server_port = 6667 # 修改端口号，避免可能的端口冲突

func _ready():
	create_button.pressed.connect(_on_create_pressed)
	join_button.pressed.connect(_on_join_pressed)
	
	# 连接网络信号
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_create_pressed():
	status_label.text = "正在创建服务器..."
	print("正在创建服务器，端口: " + str(server_port))
	
	# 如果已经有一个活跃的peer，先关闭它
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("关闭现有连接...")
		peer.close()
		await get_tree().create_timer(0.5).timeout
	
	# 创建新的peer
	peer = ENetMultiplayerPeer.new()
	
	# 创建服务器
	var error = peer.create_server(server_port, 2)  # 允许最多2个连接（1个服务器+1个客户端）
	if error != OK:
		status_label.text = "服务器创建失败！错误代码: " + str(error)
		print("服务器创建失败！错误代码: " + str(error))
		_handle_server_error(error)
		return
		
	multiplayer.multiplayer_peer = peer
	print("服务器创建中...")
	
	# 等待服务器启动
	await get_tree().create_timer(0.5).timeout
	
	var status = peer.get_connection_status()
	print("服务器连接状态: " + str(status))
	
	if status == MultiplayerPeer.CONNECTION_CONNECTED:
		status_label.text = "服务器创建成功！监听端口: " + str(server_port)
		print("服务器创建成功！监听端口: " + str(server_port))
		print("服务器ID: " + str(multiplayer.get_unique_id()))
		print("等待客户端连接...")
		
		# 设置NetworkManager状态
		NetworkManager.is_server = true
		NetworkManager.is_connected = true
		NetworkManager.player_id = multiplayer.get_unique_id()
		
		await get_tree().create_timer(1.0).timeout
		_initialize_game(true)  # true表示是服务器
	else:
		status_label.text = "服务器创建失败！状态: " + str(status)
		print("服务器创建失败！状态: " + str(status))
		
func _handle_server_error(error_code):
	"""处理服务器错误"""
	match error_code:
		ERR_CANT_CREATE:
			print("错误：无法创建服务器")
		ERR_ALREADY_IN_USE:
			print("错误：端口" + str(server_port) + "已被占用，请尝试其他端口")
		ERR_CANT_OPEN:
			print("错误：无法打开端口" + str(server_port))
		ERR_UNAVAILABLE:
			print("错误：资源不可用")
		_:
			print("未知错误：", error_code)

func _on_join_pressed():
	status_label.text = "正在连接到服务器 " + server_ip + ":" + str(server_port) + "..."
	print("尝试连接到服务器: " + server_ip + ":" + str(server_port))
	
	# 如果已经有一个活跃的peer，先关闭它
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("关闭现有连接...")
		peer.close()
		await get_tree().create_timer(0.5).timeout
	
	# 创建新的peer
	peer = ENetMultiplayerPeer.new()
	
	# 连接到服务器
	var error = peer.create_client(server_ip, server_port)
	if error != OK:
		status_label.text = "创建客户端失败！错误代码: " + str(error)
		print("创建客户端失败！错误代码: " + str(error))
		_handle_connection_error(error)
		return
		
	multiplayer.multiplayer_peer = peer
	print("客户端创建成功，等待连接...")
	
	# 设置连接超时
	await get_tree().create_timer(5.0).timeout
	
	# 检查是否已连接
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		print("连接超时！")
		status_label.text = "连接超时！请检查服务器是否运行。"
		multiplayer.multiplayer_peer = null

func _handle_connection_error(error_code):
	"""处理连接错误"""
	match error_code:
		ERR_CANT_CREATE:
			print("错误：无法创建客户端")
		ERR_ALREADY_IN_USE:
			print("错误：端口已被占用")
		ERR_CANT_OPEN:
			print("错误：无法打开连接")
		ERR_UNAVAILABLE:
			print("错误：资源不可用")
		_:
			print("未知错误：", error_code)

func _on_connected_to_server():
	status_label.text = "连接成功！"
	await get_tree().create_timer(1.0).timeout
	_initialize_game(false)  # false表示是客户端

func _on_connection_failed():
	status_label.text = "连接失败！请检查服务器是否运行。"
	print("连接失败！可能原因：")
	print("1. 服务器未运行")
	print("2. IP地址错误（当前尝试连接：" + server_ip + "）")
	print("3. 端口错误或被占用（当前端口：" + str(server_port) + "）")
	print("4. 防火墙阻止了连接")
	print("5. 网络问题")

func _on_server_disconnected():
	status_label.text = "与服务器断开连接！"
	print("与服务器断开连接！")
	
	# 重置网络状态
	NetworkManager.is_connected = false
	NetworkManager.is_server = false

func _initialize_game(is_server: bool):
	# 保存网络状态到全局变量
	NetworkManager.is_server = is_server
	NetworkManager.is_connected = true
	NetworkManager.player_id = multiplayer.get_unique_id()
	
	print("初始化游戏 - 是服务器: ", is_server)
	print("当前玩家ID: ", NetworkManager.player_id)
	
	# 切换到游戏场景
	print("切换到游戏场景...")
	get_tree().change_scene_to_file("res://scenes/main.tscn") 
