@tool
extends Node2D


@export var _hero: Hero
@export var _draw_mode: DrawMode = DrawMode.FLOATING:
	set(v):
		if v == DrawMode.ON_JUMP and not _hero.jumped.is_connected(_on_hero_jumped):
			_hero.jumped.connect(_on_hero_jumped)
		elif _hero.jumped.is_connected(_on_hero_jumped):
			_hero.jumped.disconnect(_on_hero_jumped)
		
		_draw_mode = v
		
@export var _deactivate_on_run: bool
@export var _is_active: bool

@export_group("Components")
@export var _top_point: Marker2D
@export var _bottom_point: Marker2D
@export var _raycast: RayCast2D


var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var _physics_fps: int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")

var _prev_hero_transform: Transform2D
var _draw_points: Array[Vector2]

var _draw_colors: Array = [Color.RED, Color.BLUE]


func _ready() -> void:
	if _deactivate_on_run and not Engine.is_editor_hint():
		_is_active = false
	
	if _draw_mode != DrawMode.ON_JUMP:
		return
	
	_hero.jumped.connect(_on_hero_jumped)


func _on_hero_jumped() -> void:
	if _draw_mode != DrawMode.ON_JUMP:
		return
	
	_draw_points = [_bottom_point.global_position]
	queue_redraw()


func _draw() -> void:
	if not _is_active:
		return
	
	var draw_color_idx = 0
	for point in _draw_points:
		var color = _draw_colors[draw_color_idx]
		
		_draw_jump_path(point, _hero._jump_0_force,
			color * Color(1, 1, 1) * Color(0.4, 0.4, 0.4), 1)
		_draw_jump_path(point, _hero._jump_1_force,
			color * Color(1, 1, 1) * Color(0.7, 0.7, 0.7), 1.25)
		_draw_jump_path(point, _hero._jump_2_force,
			color * Color(1, 1, 1), 1.5)
		
		draw_color_idx += 1


func _draw_jump_path(offset: Vector2, jump_force: float, color: Color, weight: float) -> void:
	var hero_jump_vector = Vector2.UP.rotated(_hero.rotation) * jump_force
	var jump_path = _get_jump_path(hero_jump_vector, 1.5)
	
	_draw_path(jump_path, offset, color, weight)


func _physics_process(delta: float) -> void:
	if not _is_active:
		return
	
	match _draw_mode:
		DrawMode.FLOATING:
			if _prev_hero_transform == _hero.transform:
				return
			
			_prev_hero_transform = _hero.transform
			_draw_points = [_bottom_point.global_position, _top_point.global_position]
		
		DrawMode.FROM_PREDICTED_JUMP_POINT:
			var predicted_point = _get_predicted_jump_point()
			if predicted_point == Vector2.ZERO:
				return
			
			_draw_points = [predicted_point]
		
		_:
			return
	
	queue_redraw()


func _get_predicted_jump_point() -> Vector2:
	_raycast.global_position = _hero.global_position
	_raycast.global_rotation = _bottom_point.global_rotation
	_raycast.force_raycast_update()
	
	return _raycast.get_collision_point() if _raycast.is_colliding() else Vector2.ZERO


func _get_jump_path(velocity_vector: Vector2, duration_sec: float) -> Array[Vector2]:
	var path: Array[Vector2]
	path.append(Vector2.ZERO)
	
	var velocity = velocity_vector
	var time_to_end = duration_sec
	var prev_point = Vector2.ZERO
	while time_to_end > 0:
		velocity.y += _gravity / _physics_fps
		var current_point = prev_point + velocity / _physics_fps
		path.append(current_point)
		prev_point = current_point
		time_to_end -= 1.0 / _physics_fps
	return path


func _draw_path(path: Array[Vector2], offset: Vector2, color: Color, weight: float):
	draw_polyline(path.map(func(x):
		return x + offset), color, weight)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_jump_debuger"):
		_is_active = not _is_active
		queue_redraw()
	
	if event is InputEventKey\
	and event.is_pressed():
		if event.physical_keycode == KEY_1:
			_draw_mode = DrawMode.FLOATING
		if event.physical_keycode == KEY_2:
			_draw_mode = DrawMode.ON_JUMP
		if event.physical_keycode == KEY_3:
			_draw_mode = DrawMode.FROM_PREDICTED_JUMP_POINT



enum DrawMode {
	FLOATING,
	ON_JUMP,
	FROM_PREDICTED_JUMP_POINT,
}
