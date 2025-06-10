class_name Unit
extends Node2D

signal move_done

@export var unit_stats: UnitStats
@export var player: bool = false

@onready var tile_map_node: Node2D = %TileMapNode
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var unused_movepoints := unit_stats.movepoints
@onready var text_edit: TextEdit = $TextEdit
@onready var battle: Node2D = get_parent()
@onready var current_position: Vector2 = global_position

var current_id_path: Array[Vector2i]
var moving: bool = false
var is_selected: bool = false
var direction: Vector2

const STAB = preload("res://source/projectile/stab.tscn")

func _ready() -> void:
	if player:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	face_direction(direction)
	move_done.connect(take_action)


func _physics_process(delta: float) -> void:
	if not is_selected:
		return
	var tile_map_temp: TileMap = tile_map_node.tile_map
	var astar_grid_temp = get_parent().astar_grid
	var id_path = astar_grid_temp.get_id_path(
		tile_map_temp.local_to_map(global_position), 
		tile_map_temp.local_to_map(get_global_mouse_position())
	)
	if id_path.is_empty() == false and id_path.size()-1 <= unused_movepoints:
		battle.movepath_overlay.draw_cells(id_path)
		return
	battle.movepath_overlay.clear()


func _input(event):
	if event.is_action_pressed("move") == false or not is_selected or moving:
		return
	
	var tile_map: TileMap = tile_map_node.tile_map
	var astar_grid: AStarGrid2D = get_parent().astar_grid
	var id_path: Array = astar_grid.get_id_path(
		tile_map.local_to_map(global_position), 
		tile_map.local_to_map(get_global_mouse_position())
	).slice(1)
	
	if id_path.is_empty() == false and id_path.size() <= unused_movepoints:
		moving = true
		current_id_path = id_path
		_move(current_id_path)

func _move(id_path: Array[Vector2i]) -> void:
	var tile_map: TileMap = tile_map_node.tile_map
	var move_tween: Tween = get_tree().create_tween()
	var tween_speed: float = min(0.5, 1.5/len(id_path))
	var face_directions: Array = []
	
	battle.movable_overlay.clear()
	battle.selected_overlay.clear()
	
	for i in id_path.size():
		var id = id_path[i]
		direction = id - tile_map.local_to_map(current_position)
		face_directions.append(direction)
		current_position = tile_map.map_to_local(id)
	face_directions.append(direction)
	face_direction(face_directions[0])

	for i in id_path.size():
		var id: Vector2 = id_path[i]
		var target_position: Vector2 = tile_map.map_to_local(id)
		unused_movepoints -= 1
		text_edit.text = str(unused_movepoints)
		move_tween.tween_property(self, "position", target_position, tween_speed)
		move_tween.tween_callback(face_direction.bind(face_directions[i+1]))
	move_tween.tween_callback(_done_moving)
	

func _done_moving() -> void:
	moving = false
	battle.get_grid()
	battle.draw_walkable_tiles(self)
	if unused_movepoints == 0:
		emit_signal("move_done")


func face_direction(direction: Vector2) -> void:
	match direction:
		Vector2.RIGHT:
			sprite.play("default")
			sprite.flip_h = false
		Vector2.LEFT:
			sprite.play("default")
			sprite.flip_h = true
		Vector2.UP:
			sprite.play("default_up")
		Vector2.DOWN:
			sprite.play("default_down")


func take_action() -> void:
	var tile_map: TileMap = tile_map_node.tile_map
	var projectile = STAB.instantiate()
	battle.add_child(projectile)
	projectile.hit_box.damage = 1
	projectile.global_position = tile_map.map_to_local(tile_map.local_to_map(global_position) + Vector2i(direction))
	battle.emit_signal("unit_done", self)


func take_damage(damage: int) -> void:
	print(self)
	print(damage)

#func _move(id_path: Array[Vector2i]) -> void:
	#var tile_map: TileMap = tile_map_node.tile_map
	#var move_tween: Tween = get_tree().create_tween()
	#var tween_speed: float = min(0.5, 1.5/len(id_path))
	#var face_directions = []
	#battle._movable_overlay.clear()
	#battle._selected_overlay.clear()
	#
	#for i in id_path.size():
		#var id = id_path[i]
		#direction = id - tile_map.local_to_map(current_position)
		#face_directions.append(direction)
		#current_position = tile_map.map_to_local(id)
	#face_directions.append(direction)
	#face_direction(face_directions[0])
	#for i in id_path.size():
		#var id = id_path[i]
		#var target_position = tile_map.map_to_local(id)
		#if unused_movepoints <= 0:
			#break
		#unused_movepoints -= 1
		#text_edit.text = str(unused_movepoints)
		#move_tween.tween_property(self, "position", target_position, tween_speed)
		#move_tween.tween_callback(face_direction.bind(face_directions[i+1]))
	#move_tween.tween_callback(_done_moving)
