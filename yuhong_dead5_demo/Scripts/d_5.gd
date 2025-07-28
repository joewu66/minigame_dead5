extends Node2D

@onready var players: Node = $Players
const PLAYER_HUMAN = preload("res://Scenes/player_human.tscn")

#创建服务器的变量
var peer = ENetMultiplayerPeer.new()

#创建服务器
func _on_create_button_up() -> void:
	#创建监听的服务器，ip地址为127.0.0.1：6666
	var error = peer.create_server(7788)
	if error != OK:
		printerr("服务器创建失败，错误码", error)
		return
	multiplayer.multiplayer_peer = peer
	#作为服务器监听客户端的连接
	multiplayer.peer_connected.connect(_on_peer_connected)
	#客户端创建成功后，在当前场景添加玩家
	add_player(multiplayer.get_unique_id()) #add_player(multiplayer.get_unique_id())用于获取当前客户端的唯一id，服务器id一般是1

#创建客户端
func _on_join_button_down() -> void:
	#创建客户端并连接ip为127.0.0.1：6666的服务器
	peer.create_client("10.46.45.51", 7788)
	multiplayer.multiplayer_peer = peer

func add_player(id: int) -> void:
	var player = PLAYER_HUMAN.instantiate()
	player.name = str(id)
	players.add_child(player)

#当有客户端连接时，该方法会被触发,该方法只有主机端会被触发
func _on_peer_connected(id: int) -> void:
	print("有玩家连接", id)
	#添加新玩家
	add_player(id)
	pass
