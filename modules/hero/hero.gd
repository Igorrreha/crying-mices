extends CharacterBody2D


signal jumped
signal backfliped
signal frontfliped
signal double_backfliped
signal double_frontfliped


@export var _jump_force = 400.0

@export_group("Components")
@export var _pogo_jump_pad_area: Area2D
@export var _flip_recognizer: FlipRecognizer


var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	_pogo_jump_pad_area.body_entered.connect(_jump.unbind(1))
	_flip_recognizer.flip_ended.connect(_on_flip_end)


func _jump() -> void:
	velocity = Vector2.UP.rotated(rotation) * _jump_force
	jumped.emit()
	move_and_slide()


func _physics_process(delta: float) -> void:
	_update_rotation()
	_apply_gravity(delta)
	move_and_slide()


func _apply_gravity(frame_delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * frame_delta


func _update_rotation() -> void:
	rotation = get_global_mouse_position().angle_to_point(global_position) + PI / 2


func _on_flip_end(angle_delta: float) -> void:
	if angle_delta > PI:
		if angle_delta > PI * 3:
			double_frontfliped.emit()
		else:
			frontfliped.emit()
		
		print("f")
	
	if angle_delta < -PI:
		if angle_delta < -PI * 3:
			double_backfliped.emit()
		else:
			backfliped.emit()
		
		print("b")
