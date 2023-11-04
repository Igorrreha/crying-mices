@tool
class_name CameraFocusPoint
extends Node2D


var _camera_polygon: Array[Vector2] = [
	Vector2(1, 0), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(1, 0),
	Vector2(2, -1), Vector2(2, 1), Vector2(1, 0),
]


func activate() -> void:
	var camera = get_viewport().get_camera_2d()
	camera.global_position = global_position


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	draw_polyline(_camera_polygon.map(func(x):
		return x * 16.0), Color.RED)
	
	var display_window_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
	var focus_rect = Rect2(-display_window_size / 2, display_window_size)
	draw_rect(focus_rect, Color.RED, false)
	
	draw_line(focus_rect.position, focus_rect.size + focus_rect.position,
		Color.RED * Color(1, 1, 1, 0.5))
	draw_line(focus_rect.position + Vector2(0, focus_rect.size.y),
		focus_rect.position + Vector2(focus_rect.size.x, 0), Color.RED * Color(1, 1, 1, 0.5))
