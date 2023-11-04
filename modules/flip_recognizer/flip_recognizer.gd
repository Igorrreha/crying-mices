class_name FlipRecognizer
extends Node


signal flip_ended(angle_delta: float)


@export var _observable_object: Node2D
@export var _start_flip_signal: StringName
@export var _end_flip_signal: StringName


var _flip_in_process: bool
var _flip_start_angle: float

var _prev_frame_rotation: float
var _flip_delta: float


func _ready() -> void:
	_observable_object.connect(_end_flip_signal, _on_flip_ended)
	_observable_object.connect(_start_flip_signal, _on_flip_started)


func _exit_tree() -> void:
	_observable_object.disconnect(_start_flip_signal, _on_flip_started)
	_observable_object.disconnect(_end_flip_signal, _on_flip_ended)


func _process(delta: float) -> void:
	if _flip_in_process:
		_calculate_rotation_step()


func _calculate_rotation_step() -> void:
	var frame_rotation_delta = Vector2.RIGHT\
		.rotated(_prev_frame_rotation)\
		.angle_to(Vector2.RIGHT.rotated(_observable_object.rotation))
	
	_flip_delta += frame_rotation_delta
	_prev_frame_rotation = _observable_object.rotation


func _on_flip_started() -> void:
	_flip_in_process = true
	_flip_start_angle = _observable_object.rotation
	_prev_frame_rotation = _flip_start_angle
	_flip_delta = 0


func _on_flip_ended() -> void:
	if not _flip_in_process:
		return
	
	_calculate_rotation_step()
	_flip_in_process = false
	
	flip_ended.emit(_flip_delta)
