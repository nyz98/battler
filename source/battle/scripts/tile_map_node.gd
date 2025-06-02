extends Node2D

@onready var tile_map: TileMap = $TileMap
@onready var current_cell: Vector2i = tile_map.local_to_map(get_global_mouse_position())

var can_draw := false

func _draw() -> void:
	draw_rect(Rect2(tile_map.map_to_local(current_cell) - Vector2(8, 8), Vector2(16, 16)), Color.ALICE_BLUE, false, 1.0)


func _physics_process(_delta: float) -> void:
	if not can_draw:
		return
		
	if tile_map.local_to_map(get_global_mouse_position()) == current_cell:
		return
	
	current_cell = tile_map.local_to_map(get_global_mouse_position())
	queue_redraw()


func _on_area_2d_mouse_exited() -> void:
	can_draw = false


func _on_area_2d_mouse_entered() -> void:
	can_draw = true
