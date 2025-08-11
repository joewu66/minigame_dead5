extends Control

@onready var create = $UI/create
@onready var join = $UI/join

const MAIN_SCENE = preload("uid://nea8u4uegl6h")
const PORT := 7788
var ip_adress := "10.46.45.35"

#创建服务器的变量
var peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	create.pressed.connect(_on_create_pressed)
	join.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server) #作为服务器监听客户端的连接
	
#按下create创建服务器
func _on_create_pressed() -> void:
	var server_peer = peer
	#创建监听的服务器，ip地址为127.0.0.1：6666
	var error = server_peer.create_server(PORT, 4)
	if error != OK:
		printerr("服务器创建失败，错误码", error)
		return
	multiplayer.multiplayer_peer = server_peer
	#切换到游戏主场景
	get_tree().change_scene_to_packed(MAIN_SCENE)
	

#按下join创建客户端
func _on_join_pressed() -> void:
	#创建客户端并连接ip为xx的服务器
	var client_peer = peer
	client_peer.create_client(ip_adress, PORT)
	multiplayer.multiplayer_peer = client_peer

#当有客户端连接时，该方法会被触发,该方法只有主机端会被触发
func _on_connected_to_server() -> void:
	#切换到游戏主场景
	get_tree().change_scene_to_packed(MAIN_SCENE)
