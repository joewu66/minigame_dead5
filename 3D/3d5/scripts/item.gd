extends Area3D

@export var slow_duration = 3.0
@export var trap_lifetime = 10.0

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

var used = false

func _ready():
	body_entered.connect(_on_body_entered)
	
	# 陷阱自动消失
	await get_tree().create_timer(trap_lifetime).timeout
	queue_free()

func _on_body_entered(body):
	if used:
		return
		
	if body is Ghost:
		used = true
		body.apply_slow_effect(slow_duration)
		
		# 视觉效果
		var tween = create_tween()
		tween.tween_property(mesh, "modulate", Color.TRANSPARENT, 0.5)
		tween.tween_callback(queue_free)
