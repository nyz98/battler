class_name HitBox
extends Area2D

@export var damage := 1


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(hurtbox: HurtBox):
	if hurtbox == null:
		return
	
	owner.queue_free()
