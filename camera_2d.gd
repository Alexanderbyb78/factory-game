extends Camera2D

@export var move_speed: float = 800.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 4.0

var target_zoom: float = 1.0

func _ready():
	target_zoom = zoom.x

func _process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	zoom_camera(delta)
	position += direction * (move_speed / zoom.x) * delta

func zoom_camera(_delta):
	if is_equal_approx(zoom.x, target_zoom):
		return
	var mouse_world = get_global_mouse_position()
	var ratio = zoom.x / target_zoom
	position = mouse_world + (position - mouse_world) * ratio
	zoom = Vector2(target_zoom, target_zoom)

func _input(event):
	if event is InputEventMouseButton:
		if event.ctrl_pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				target_zoom = clamp(target_zoom * (1.0 + zoom_speed), min_zoom, max_zoom)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				target_zoom = clamp(target_zoom * (1.0 - zoom_speed), min_zoom, max_zoom)
