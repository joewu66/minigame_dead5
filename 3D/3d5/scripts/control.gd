extends Control

@onready var timer_label = $VBoxContainer/TimerLabel
@onready var item_label = $VBoxContainer/ItemLabel
@onready var message_label = $MessageLabel
@onready var game_over_panel = $GameOverPanel
@onready var restart_button = $GameOverPanel/VBoxContainer/RestartButton
@onready var controls_label = $VBoxContainer/ControlsLabel

func _ready():
	print("UI控制脚本加载中...")
	
	# 检查所有节点是否正确加载
	if timer_label:
		print("TimerLabel 加载成功")
	else:
		print("TimerLabel 加载失败")
		
	if item_label:
		print("ItemLabel 加载成功")
	else:
		print("ItemLabel 加载失败")
		
	if message_label:
		print("MessageLabel 加载成功")
	else:
		print("MessageLabel 加载失败")
		
	if game_over_panel:
		print("GameOverPanel 加载成功")
	else:
		print("GameOverPanel 加载失败")
		
	if restart_button:
		print("RestartButton 加载成功")
		restart_button.pressed.connect(_on_restart_pressed)
	else:
		print("RestartButton 加载失败")
		
	if controls_label:
		print("ControlsLabel 加载成功")
	else:
		print("ControlsLabel 加载失败")
	
	game_over_panel.hide()

func update_timer(time: float):
	if timer_label:
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		timer_label.text = "时间: %02d:%02d" % [minutes, seconds]

func update_item_count(count: int):
	if item_label:
		item_label.text = "减速陷阱: %d" % count

func show_message(text: String, duration: float):
	if message_label:
		message_label.text = text
		message_label.show()
		
		await get_tree().create_timer(duration).timeout
		message_label.hide()
	else:
		print("MessageLabel 不可用，无法显示消息: ", text)

func show_game_over(message: String):
	if game_over_panel:
		game_over_panel.show()
		var game_over_message = game_over_panel.get_node("VBoxContainer/MessageLabel")
		if game_over_message:
			game_over_message.text = message
		else:
			print("游戏结束消息标签未找到")
	else:
		print("游戏结束面板未找到")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_pressed():
	# 返回主菜单
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
