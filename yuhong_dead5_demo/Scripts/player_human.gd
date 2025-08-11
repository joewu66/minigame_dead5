extends CharacterBody2D
class_name Player_Human

@onready var inventory: Control = $Inventory
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var items_container = $"../../Items_container"
@onready var camera_2d = $Camera2D
@onready var shadow = $Shadow
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ghost_sprite: AnimatedSprite2D = $ghost_sprite
@onready var point_light_2d: PointLight2D = $PointLight2D


@export var speed = 300
@export var health = 100
@export var is_ghost := false

var quick_bar_item_selected: ConsumableData
var grid_id: Vector2

func _enter_tree() -> void:
	#设置该节点的多人权限
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	gamemanager.player = self
	init_player_human()

#初始化玩家
func init_player_human():
	
	inventory.visible = false
	position = Vector2(randf_range(100,200),randf_range(100,200))
	
	#设置相机权限，本机再启用相机
	if is_multiplayer_authority():
		camera_2d.enabled = true
	else:
		camera_2d.enabled = false

func _physics_process(delta: float) -> void:
	#如果不是该节点的控制者，则无法移动，直接终止方法
	#根据设置的节点的权限id，与本身的唯一id做对比，如果一致，则权限正确
	#get_unique_id获取的id即为本机的id标识，在创建客户端或服务器时生成
	if not is_multiplayer_authority():
		return
	
	#移动
	move()
	
	#按键开关背包
	if Input.is_action_just_pressed("open_inventory"):
		toggle_inventory()
	
	#监听切换道具
	for i in range(1, 7):
		if Input.is_action_just_pressed("select_quick_bar_" + str(i)):
			grid_id = switch_quick_bar_items(i)
			
	#监听使用道具
	if Input.is_action_just_pressed("inv_use") and grid_id:
		print("used")
		use_selected_item(grid_id)
		
	if Input.is_action_just_pressed("turn_ghost"):
		turn_ghost()
		
	if Input.is_action_just_pressed("light_on"):
		light_on()

func move():
	#上下左右移动
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	
	move_and_slide()

#开关背包
func toggle_inventory():
	inventory.visible = not inventory.visible
	
#切换快捷栏道具
func switch_quick_bar_items(x):
	grid_id = Vector2(x, 1)
	return grid_id

#使用道具的方法
func use_selected_item(grid_id):
	GBIS.inventory_service.use_item(gamemanager.player_1_inv_name, grid_id)

#丢弃道具的方法
func throw_item(item_data: ItemData) -> void:
	var drop_position = self.position
	var drop = Item.drop_item(drop_position, item_data)
	items_container.add_child(drop)
	drop.sprite.add_child(item_data.drop_model.instantiate()) #加载丢弃道具的立绘
	
func turn_ghost():
	ghost_sprite.visible = true
	animated_sprite.visible = false
	speed = 350
	point_light_2d.scale = Vector2(100, 100)

func light_on():
	point_light_2d.scale = Vector2(100, 100)
