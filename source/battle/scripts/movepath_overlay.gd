## Draws a selected unit's walkable tiles.
extends TileMapLayer


## Fills the tilemap with the cells, giving a visual representation of the cells a unit can walk.
func draw_cells(cells: Array) -> void:
	clear()
	set_cells_terrain_path(cells, 0, 0)
