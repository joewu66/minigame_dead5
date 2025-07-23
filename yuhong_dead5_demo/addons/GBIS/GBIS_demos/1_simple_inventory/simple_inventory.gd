extends Control

@onready var inventory: ColorRect = $Inventory
@onready var storage: ColorRect = $Storage

func _ready() -> void:
	GBIS.add_quick_move_relation("demo1_inventory", "demo1_storage")
	GBIS.add_quick_move_relation("demo1_storage", "demo1_inventory")

func _on_button_close_inventory_pressed() -> void:
	inventory.hide()

func _on_button_close_storage_pressed() -> void:
	storage.hide()

func _on_button_toggle_inventory_pressed() -> void:
	inventory.visible = not inventory.visible

func _on_button_toggle_storage_pressed() -> void:
	storage.visible = not storage.visible

func _on_button_add_test_items_pressed() -> void:
	var item_1 = load("res://addons/GBIS/GBIS_demos/resources/equipment_1.tres")
	var item_2 = load("res://addons/GBIS/GBIS_demos/resources/stackable_1.tres")
	var item_3 = load("res://addons/GBIS/GBIS_demos/resources/consumable_1.tres")
	GBIS.add_item("demo1_inventory", item_1)
	GBIS.add_item("demo1_inventory", item_2)
	GBIS.add_item("demo1_inventory", item_3)

func _on_button_save_pressed() -> void:
	GBIS.save()

func _on_button_load_pressed() -> void:
	GBIS.load()
