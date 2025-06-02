class_name Unit
extends Node2D

@export var unit_stats: UnitStats
@export var player: bool = false

@onready var tile_map_node: Node2D = %TileMapNode
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var remaining_movement := unit_stats.movement_points
@onready var text_edit: TextEdit = $TextEdit

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

func _move(id_path: Array[Vector2i]) -> void:
	var tile_map: TileMap = tile_map_node.tile_map
	var move_tween: Tween = get_tree().create_tween()
	var tween_speed: float = min(0.5, 1.5/len(id_path))
	var battle: Node2D = get_parent()
	battle._unit_overlay.clear()
	sprite.play("moving")
	for id in id_path:
		var target_position = tile_map.map_to_local(id)
		if remaining_movement <= 0:
			move_tween.tween_callback(_done_moving)
			break
		remaining_movement -= 1
		text_edit.text = str(remaining_movement)
		move_tween.tween_property(self, "position", target_position, tween_speed)
	move_tween.tween_callback(_done_moving)
	

func _done_moving() -> void:
	var battle: Node2D = get_parent()
	sprite.play("default")
	moving = false
	battle.draw_walkable_tiles(self)
	if remaining_movement == 0:
		battle.emit_signal("unit_done", self)


#func _get_total_movement_cost(tile_map: TileMap, location: Vector2) -> int:
	#var total_layers = tile_map.get_layers_count()
	#var total_movement_cost = 0
	#for layer in total_layers:
		#var tile_data = tile_map.get_cell_tile_data(layer, location)
		#if tile_data != null:
			#total_movement_cost += tile_data.get_custom_data("cost")
	#return total_movement_cost
