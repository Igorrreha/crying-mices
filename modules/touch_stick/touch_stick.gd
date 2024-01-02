@tool
extends Control


signal activated
signal deactivated
signal output_updated(Vector2)


@export_group("Base")
@export var _base_radius: float:
	set(v):
		_base_radius = v
		queue_redraw()
@export var _base_color: Color:
	set(v):
		_base_color = v
		queue_redraw()
@export var _base_width: int:
	set(v):
		_base_width = v
		queue_redraw()

@export_group("Stick")
@export var _stick_radius: float:
	set(v):
		_stick_radius = v
		queue_redraw()
@export var _stick_color: Color:
	set(v):
		_stick_color = v
		queue_redraw()


var _is_active: bool
var _touch_idx: int = -1


@onready var _stick: Control = $Stick
@onready var _stick_space_radius: float = _base_radius - _stick_radius


func _draw() -> void:
	draw_arc(Vector2.ZERO, _base_radius + _base_width / 2.0 + 1.0, 0, TAU, 64,
		_base_color, _base_width, true)
	draw_circle(_stick.position, _stick_radius, _stick_color)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_released()\
		and event.index == _touch_idx:
			_deactivate()
			return
			
		var relative_input_position = event.position - global_position
		
		if event.is_pressed()\
		and not _is_active\
		and relative_input_position.length() <= _base_radius:
			_activate(event.index, relative_input_position)
			return
	
	if event is InputEventScreenDrag\
	and _is_active\
	and event.index == _touch_idx:
		var relative_input_position = event.position - global_position
		_update_output_value(relative_input_position)


func _activate(touch_idx: int, input_position: Vector2) -> void:
	_is_active = true
	_touch_idx = touch_idx
	_update_output_value(input_position)
	activated.emit()


func _deactivate() -> void:
	_is_active = false
	_touch_idx = -1
	_update_output_value(Vector2.ZERO)
	deactivated.emit()


func _update_output_value(relative_input_position: Vector2) -> void:
	if not _is_active:
		_stick.position = Vector2.ZERO
		output_updated.emit(Vector2.ZERO)
		queue_redraw()
		return
	
	_stick.position = relative_input_position.limit_length(_stick_space_radius)
	queue_redraw()
	
	var output_value = _stick.position.normalized()\
		* (_stick.position.length() / _stick_space_radius)
	output_updated.emit(output_value)
