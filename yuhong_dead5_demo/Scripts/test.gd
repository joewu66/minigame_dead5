extends Node2D

func _ready() -> void:
	var b = test(0)
	print(b)

func test(a):
	print("func is called")
	return 2
