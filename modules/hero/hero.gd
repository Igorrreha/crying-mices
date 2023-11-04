class_name Hero
extends CharacterBody2D


signal jumped
signal backfliped
signal frontfliped
signal double_backfliped
signal double_frontfliped


@export var _jump_0_force = 350.0
@export var _jump_1_force = 450.0
@export var _jump_2_force = 550.0

@export_group("Components")
@export var _pogo_jump_pad_area: Area2D
@export var _flip_recognizer: FlipRecognizer

var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var _cur_jump_type: JumpType


func _ready() -> void:
	_pogo_jump_pad_area.body_entered.connect(_jump.unbind(1))
	_flip_recognizer.flip_ended.connect(_on_flip_end)


func _jump() -> void:
	jumped.emit()
	
	var jump_force: float = _jump_0_force
	match _cur_jump_type:
		JumpType.SUPER:
			jump_force = _jump_1_force
			_cur_jump_type = JumpType.DEFAULT
		JumpType.ULTRA:
			jump_force = _jump_2_force
			_cur_jump_type = JumpType.DEFAULT
	
	velocity = Vector2.UP.rotated(rotation) * jump_force
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
			_cur_jump_type = JumpType.ULTRA
		else:
			frontfliped.emit()
			_cur_jump_type = JumpType.SUPER
		
		print("f")
	
	if angle_delta < -PI:
		if angle_delta < -PI * 3:
			double_backfliped.emit()
			_cur_jump_type = JumpType.ULTRA
		else:
			backfliped.emit()
			_cur_jump_type = JumpType.SUPER
		
		print("b")


enum JumpType {
	DEFAULT,
	SUPER,
	ULTRA,
}
