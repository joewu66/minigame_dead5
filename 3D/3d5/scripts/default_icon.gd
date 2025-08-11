extends Node

# 默认图标资源
static func get_default_icon() -> Texture2D:
	# 尝试加载默认图标
	var texture = load("res://models/medieval/Textures/cobblestone.png")
	if texture == null:
		print("警告：无法加载默认图标")
	return texture