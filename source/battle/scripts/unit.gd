class_name Unit
extends Node2D

@export var unit_stats: UnitStats
@export var player: bool = false

@onready var tile_map_node: Node2D = %TileMapNode
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_id_path: Array[Vector2i]
var moving: bool = false
var is_selected: bool = false



func _input(event):
	if event.is_action_pressed("move") == false:
		return
	
	if not is_selected:
		return
	
	if moving:
		return
	
	var tile_map: TileMap = tile_map_node.tile_map
	moving = true
	var astar_grid = get_parent().astar_grid
	var id_path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position), 
		tile_map.local_to_map(get_global_mouse_position())
	).slice(1)
	
	if id_path.is_empty() == false:
		current_id_path = id_path
	_move(current_id_path)

func _move(current_id_path: Array[Vector2i]) -> void:
	var tile_map: TileMap = tile_map_node.tile_map
	var move_tween: Tween = get_tree().create_tween()
	var tween_speed: float = 1.5/len(current_id_path)
	print(tween_speed)
	sprite.play("moving")
	for id in current_id_path:
		var target_position = tile_map.map_to_local(id)
		move_tween.tween_property(self, "position", target_position, tween_speed)
	move_tween.tween_callback(_done_moving)
	

func _done_moving() -> void:
	sprite.play.bind("default")
	moving = false
	is_selected = false
	var battle: Node2D = get_parent()
	battle.emit_signal("unit_done", self)
