extends CharacterBody2D
class_name Player_Human

@onready var inventory: Control = $Inventory
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var items_container: Node = $"../Items_container"

const SPEED = 600
var quick_bar_item_selected: ConsumableData
var grid_id: Vector2

func _ready() -> void:
	gamemanager.player = self
	init_player_human()

#初始化玩家
func init_player_human():
	inventory.visible = false

func _physics_process(delta: float) -> void:
	
	#上下左右移动
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
	
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
