extends Area2D
@onready var label: Label = $Label
	
func _on_body_entered(body: Node2D) -> void:
	#靠近显示label
	label.visible = true

func _on_body_exited(body: Node2D) -> void:
	label.visible = false
	
func _process(delta: float) -> void:
	if label.visible and Input.is_action_just_pressed("pick_up"):
		var item_picked_up = load("res://Resources/test_item.tres") 
		GBIS.add_item("Inventory", item_picked_up)
	
