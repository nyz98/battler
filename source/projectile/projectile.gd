extends Node2D

@onready var hit_box: HitBox = $HitBox

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	queue_free()
