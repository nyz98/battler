extends Node2D

signal unit_done

@onready var tile_map_node: Node2D = %TileMapNode
@onready var movable_overlay: TileMapLayer = %MovableOverlay
@onready var selected_overlay: TileMapLayer = %SelectedOverlay
@onready var movepath_overlay: TileMapLayer = %MovepathOverlay

## Mapping of coordinates of a cell to a reference to the unit it contains.
var astar_grid: AStarGrid2D
var unit_queue: Array[Unit] = []
var current_grid: Vector2
var walkable_tiles: Array

func _ready():
	_setup_astar_grid()
	sort_unit_queue()
	get_grid()
	draw_walkable_tiles(unit_queue[0])


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
	var unit_positions = get_units_position(tile_map)
	_setup_astar_grid()

	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			if tile_position in unit_positions:
				astar_grid.set_point_solid(tile_position)
				
			for layer in tile_map.get_layers_count():
				var tile_data = tile_map.get_cell_tile_data(layer, tile_position)
				if tile_data == null:
					continue
				if tile_data.get_custom_data("walkable") == false:
					astar_grid.set_point_solid(tile_position)



func _get_walkable_tiles(active_unit: Unit) -> Array:
	var tile_map: TileMap = tile_map_node.tile_map
	walkable_tiles =  []
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			if astar_grid.is_point_solid(tile_position):
				continue
			var id_path = astar_grid.get_id_path(
				tile_map.local_to_map(active_unit.global_position), 
				tile_position
			).slice(1)
			if len(id_path) <= active_unit.unused_movepoints and len(id_path) > 0:
				walkable_tiles.append(tile_position)
	return walkable_tiles


func _on_unit_done(done_unit: Unit) -> void:
	done_unit.is_selected = false
	get_grid()
	unit_queue.erase(done_unit)
	
	if not unit_queue.is_empty():
		unit_queue[0].is_selected = true
		draw_walkable_tiles(unit_queue[0])
		


func _on_button_pressed() -> void:
	unit_queue[0].emit_signal("move_done")


func _setup_astar_grid() -> void:
	var tile_map = tile_map_node.tile_map
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

func draw_walkable_tiles(unit: Unit) -> void:
	walkable_tiles = _get_walkable_tiles(unit)
	movable_overlay.draw_cells(walkable_tiles)
	selected_overlay.draw_cells([tile_map_node.tile_map.local_to_map(unit.global_position)])

func get_units_position(tile_map: TileMap) -> Array:
	var unit_positions: Array = []
	for unit in unit_queue:
		unit_positions.append(tile_map.local_to_map(unit.global_position))
	return unit_positions
