extends Area3D

class_name PickupItem

const DefaultIcon = preload("res://scripts/default_icon.gd")

@export var item_type: int = 0  # 默认为减速陷阱
@export var item_name: String = "减速陷阱"
@export var item_texture: Texture
@export var pickup_sound: AudioStream
@export var pickup_effect_scene: PackedScene

@onready var mesh = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@onready var animation_player = $AnimationPlayer

var can_pickup = true

func _ready():
	body_entered.connect(_on_body_entered)
	
	# 如果有动画播放器，播放浮动动画
	if animation_player and animation_player.has_animation("float"):
		animation_player.play("float")

func _on_body_entered(body):
	if not can_pickup:
		return
		
	if body is Human:
		pickup(body)

func pickup(player):
	if not can_pickup:
		return
		
	can_pickup = false
	
	# 尝试添加到玩家背包
	if player.has_method("add_to_inventory"):
		# 调试信息：检查纹理是否有效
		print("拾取物品: ", item_name)
		print("纹理资源: ", item_texture)
		
		# 如果纹理为空，使用默认纹理
		if item_texture == null:
			print("警告：物品纹理为空，使用默认纹理")
			# 使用默认图标工具类
			item_texture = DefaultIcon.get_default_icon()
			print("加载默认纹理结果: ", item_texture)
			
		var success = player.add_to_inventory(item_type, item_name, item_texture)
		print("添加到背包结果: ", success)
		
		if success:
			# 确保触发背包更新信号
			player.emit_signal("inventory_updated")
			
			# 打印调试信息
			print("物品拾取成功，检查player.inventory_ui是否存在:", player.inventory_ui != null)
			
			# 尝试直接更新背包UI
			if player.inventory_ui:
				print("拾取物品后直接调用player.inventory_ui.update_ui")
				if player.inventory_ui.has_method("update_ui"):
					player.inventory_ui.update_ui(player.inventory)
					player.inventory_ui.highlight_slot(player.selected_slot)
				else:
					print("警告：背包UI没有update_ui方法")
			print("已触发背包更新信号")
			# 播放拾取音效
			if pickup_sound:
				var audio = AudioStreamPlayer3D.new()
				audio.stream = pickup_sound
				audio.position = global_position
				get_tree().root.add_child(audio)
				audio.play()
				audio.finished.connect(func(): audio.queue_free())
			
			# 播放拾取特效
			if pickup_effect_scene:
				var effect = pickup_effect_scene.instantiate()
				effect.global_position = global_position
				get_tree().root.add_child(effect)
			
			# 隐藏并删除物品
			var tween = create_tween()
			tween.tween_property(mesh, "scale", Vector3.ZERO, 0.3)
			tween.tween_callback(queue_free)
		else:
			# 背包已满，恢复可拾取状态
			can_pickup = true
