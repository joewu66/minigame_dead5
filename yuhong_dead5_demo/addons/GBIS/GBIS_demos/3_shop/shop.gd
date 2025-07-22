extends Control

@onready var inventory: ColorRect = $Inventory
@onready var shop: ColorRect = $Shop

func _ready() -> void:
	GBIS.current_inventories = ["demo3_inventory"]

func _on_button_close_inventory_pressed() -> void:
	inventory.hide()

func _on_button_close_shop_pressed() -> void:
	shop.hide()

func _on_button_toggle_inventory_pressed() -> void:
	inventory.visible = not inventory.visible

func _on_button_toggle_shop_pressed() -> void:
	shop.visible = not shop.visible

func _on_button_add_test_items_pressed() -> void:
	var item_1 = load("res://GBIS_demos/resources/equipment_1.tres")
	var item_2 = load("res://GBIS_demos/resources/stackable_1.tres")
	var item_3 = load("res://GBIS_demos/resources/consumable_1.tres")
	GBIS.add_item("demo3_inventory", item_1)
	GBIS.add_item("demo3_inventory", item_2)
	GBIS.add_item("demo3_inventory", item_3)

func _on_button_save_pressed() -> void:
	GBIS.save()

func _on_button_load_pressed() -> void:
	GBIS.load()
