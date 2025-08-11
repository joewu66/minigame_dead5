extends Node2D

@onready var players: Node = $Players
@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var timer: Timer = $Timer
@onready var shadow: CanvasModulate = $Shadow

const PLAYER_SCENE = preload("uid://c0lh5brvfiqcq")
var connected_players = []
const GHOST_SCENE = preload("uid://ded2lspgx8o0g")
var ghost

func _ready():
	multiplayer_spawner.spawn_function = func(data):  #重新命名一个函数，因为这个函数不想被调用，所以在此声明
		var player = PLAYER_SCENE.instantiate()
		player.name = str(data.peer_id)
		return player
	
	peer_ready.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id" : sender_id})  #调用ready里的那个函数
	connected_players.append(sender_id) #存储已连接的玩家的id
	
	# 检查是否已连接到 5 个玩家
	#if connected_players.size() == 2:
		## 如果有 5 个玩家，调用方法来变鬼
		#await turn_human_to_ghost()



#转换为鬼的方法，并返回鬼的节点
#@rpc("any_peer", "call_local", "reliable")
#func turn_human_to_ghost():
	##随机选取一个玩家的id
	#var random_peer_id = connected_players[randi_range(0, connected_players.size()-1)]
	##获得该玩家的player节点
	#var random_player = players.get_node(str(random_peer_id))
	#if random_player:
		#random_player.turn_ghost()
	#if random_player:
		#print(random_player)
		#
		#random_player.speed = 900
		#random_player.health = 1000
		#random_player.animated_sprite.scale = Vector2(3.0,3.0)
		#random_player.animated_sprite.visible = false
		#random_player.ghost_sprite.visible = true
#
	#return random_player
	
#func output_random_position():
#
	#var position_lefttop = Vector2(randf_range(-1500, -1300), randf_range(-800, -500))
	#var position_mid = Vector2(randf_range(100, 400), randf_range(100, 500))
	#var position_bottom = Vector2(randf_range(100, 400), randf_range(2500, 2700))
	#var position_righttop = Vector2(randf_range(2350, 2500), randf_range(-600, -500))
	#var position_leftbottom = Vector2(randf_range(-1800, -1600), randf_range(3200, 3350))
	#
	#var positions = [position_lefttop, position_mid, position_bottom, position_righttop, position_leftbottom]
	#print(positions)
	#for i in range(5):
		#var player_node = players.get_node(str(connected_players[i]))
		#player_node.position = positions[i]
