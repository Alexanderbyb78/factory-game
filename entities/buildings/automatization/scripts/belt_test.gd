extends Node2D

@export var belt_id := 0
@export var next_belt_id := 0

@onready var belt : belt_logic_reverse = belt_logic_reverse.new()
var _overlay : Node2D = Node2D.new()

#var item_textures = [
	#preload("uid://cu1aja1tj0oso"), # COAL
	#preload("uid://cqylia73cxhv"), # COPPER_BAR
	#preload("uid://dley4ywlceu48"), # COPPER_ORE
	#preload("uid://cfoks4y7mxumx"), # GEAR
	#preload("uid://cg0o8y7b8wsws"), # GLASS
	#preload("uid://bjbhoowyeawmc"), # IRON_ORE
	#preload("uid://cdp2pbjfnss4a"), # IRON_PLATE
	#preload("uid://ck85uup7rifwp"), # SAND
	#preload("uid://kfgka6l1cvno"), # PCB
	#preload("uid://dsulsbpa5kec1"), # SUPER_RARE
	#preload("uid://bim1twk18vnsv"), # WIRE
	#preload("uid://d2t4dw7x3fd2i"), # LIGHT_BULB
#]

func _ready():
	#belt.next_belt = next_belt
	if not has_node("Overlay"):
		_overlay.name = "Overlay"
		_overlay.z_index = 13
		add_child(_overlay)
		_overlay.draw.connect(_on_overlay_draw)

func _physics_process(_delta):
	_overlay.queue_redraw()
	if Input.is_action_pressed("RMB"):
		belt.move_tick()
		queue_redraw()

func _draw():
	draw_line(Vector2.ZERO, Vector2(belt.L,0), Color.BLACK, 0.5)
	if belt.item_ids.is_empty(): return
	var pos = belt.get_positions()
	for i in belt.item_ids.size():
		#var tex = item_textures[belt.item_ids[i]]
		var x = pos[i]
		#var rect = Rect2(Vector2(x - belt.item_size*0.8/2.0, -belt.item_size*0.8/2.0), Vector2(belt.item_size*0.8, belt.item_size*0.8))
		#draw_texture_rect(tex, rect, false)
		draw_circle(Vector2(x, 0), belt.item_size/2.0, Color.BLACK, false, 0.5)

func _on_overlay_draw():
	if not belt: return
	var mouse_pos = get_local_mouse_position().round()
	if mouse_pos.x<0 or mouse_pos.x>belt.L: return
	if abs(mouse_pos.y)>64: return
	var can = belt.can_add_item(mouse_pos.x)
	var color = Color.GREEN if can else Color.RED
	_overlay.draw_line(mouse_pos, Vector2(mouse_pos.x, 0), color, 0.5)
	_overlay.draw_line(Vector2(mouse_pos.x - belt.item_size/2.0, 0), Vector2(mouse_pos.x + belt.item_size/2.0, 0), color, 0.5)
	_overlay.draw_circle(Vector2(mouse_pos.x, 0), belt.item_size/2.0, color, false, 0.5)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var m_pos = get_local_mouse_position().round().x
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not belt: return
			if m_pos<0 or m_pos>belt.L: return
			if abs(get_local_mouse_position().y) > 64: return
			var rand_id : int = 0
			#rand_id = randi() % item_textures.size()
			if belt.can_add_item(m_pos):
				belt.add_item(int(m_pos), rand_id)
			queue_redraw()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			belt.move_tick()
			queue_redraw()
