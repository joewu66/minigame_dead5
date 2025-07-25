extends CharacterBody2D

@export var character_vector = Vector2.ZERO ## 角色的朝向
@export var character_speed: float ## 角色的移动速度


func _process(delta: float) -> void:
	character_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") ## 移动的四个方向
	if character_vector.length() > 0:
		position += character_vector * delta * character_speed ## 角色的位置等于向量乘以delta乘以移动速度
	move_and_slide()
