extends Node2D

signal unit_done

@onready var tile_map_node: Node2D = %TileMapNode
@onready var _unit_overlay: TileMap = %UnitOverlay

## Mapping of coordinates of a cell to a reference to the unit it contains.
var astar_grid: AStarGrid2D
var _active_unit: Unit
var _walkable_cells := []
var unit_queue: Array[Unit] = []
var current_grid: Vector2




func _ready():
	astar_grid = AStarGrid2D.new()
	get_grid()
	sort_unit_queue()


func sort_unit_queue() -> void:
	get_unit_queue()
	unit_queue.sort_custom(is_faster)
	unit_queue[0].is_selected = true


func get_unit_queue() -> void:
	for child in get_children():
		if child is Unit:
			unit_queue.append(child)


static func is_faster(a: Unit, b: Unit) -> bool:
	return a.unit_stats.speed > b.unit_stats.speed


func get_grid():
	var tile_map = tile_map_node.tile_map
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)


func _on_unit_done(done_unit: Unit) -> void:
	done_unit.is_selected = false
	unit_queue.erase(done_unit)
	
	if not unit_queue.is_empty():
		unit_queue[0].is_selected = true


func _on_button_pressed() -> void:
	emit_signal("unit_done", unit_queue[0])
