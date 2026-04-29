extends Node2D

var d : = 0:
	set(x):
		d = x
		overlay.queue_redraw()

var overlay : Node2D = Node2D.new()

var tiles : Dictionary = {}

const TILE = 16
const COLORS = [
	Color(0.0, 0.617, 0.76, 1.0),
	Color(0.795, 0.216, 1.0, 1.0),
	Color(0.859, 0.411, 0.0, 1.0),
	Color(0.417, 0.632, 0.0, 1.0)
]

var half_tile = Vector2(TILE, TILE)/2.0

func _ready() -> void:
	add_child(overlay)
	overlay.draw.connect(_overlay_draw)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if range(49, 53).has(event.keycode):
			d = event.keycode - 49
	
	if event is InputEventMouseButton and event.is_pressed() and not event.ctrl_pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			d = wrapi(d+1, 0, 4)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			d = wrapi(d-1, 0, 4)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			var tile_pos = round(get_global_mouse_position()/TILE)
			tiles[tile_pos] = d
			queue_redraw()
			overlay.queue_redraw()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var tile_pos = round(get_global_mouse_position()/TILE)
			tiles.erase(tile_pos)
			queue_redraw()
			overlay.queue_redraw()
	if event is InputEventMouseMotion:
		overlay.queue_redraw()

func _draw() -> void:
	var color : Color
	for t in tiles:
		var rect = Rect2(t*TILE-half_tile, Vector2(TILE,TILE))
		color = COLORS[tiles[t]]
		draw_rect(rect, color)

func _overlay_draw():
	var tile_pos = round(get_global_mouse_position()/TILE)
	var color : Color = COLORS[d]
	var rect = Rect2(tile_pos*TILE-half_tile, Vector2(TILE,TILE))
	if tiles.has(tile_pos):
		rect = rect.grow(TILE/-12.0)
		overlay.draw_rect(rect, color, false, TILE/6.0)
	else:
		color.a = 0.5
		overlay.draw_rect(rect, color)
