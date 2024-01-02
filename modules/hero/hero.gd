class_name Hero
extends CharacterBody2D


signal jumped
signal backfliped
signal frontfliped
signal double_backfliped
signal double_frontfliped

signal dead

signal became_movable


@export var _dummy: bool
@export var _hp: int
@export var _jump_0_force = 350.0
@export var _jump_1_force = 450.0
@export var _jump_2_force = 550.0

@export var _signals_channel: HeroSignalsChannel

@export_group("Components")
@export var _pogo_jump_pad_area: Area2D
@export var _flip_recognizer: FlipRecognizer

@export_group("Input")
@export var _rotation_stick_state: TouchStickState


var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var _cur_jump_type: JumpType

var _immovable: bool = true:
	set(v):
		if v == false:
			became_movable.emit()
		_immovable = v


@onready var _default_jump_sfx_player: AudioStreamPlayer2D = $Jump0


func become_immovable() -> void:
	velocity = Vector2.ZERO
	_immovable = true


func take_damage(amount: int) -> void:
	_hp = clamp(_hp - amount, 0, INF)
	if _hp == 0:
		dead.emit()
		_signals_channel.dead.emit()


func _ready() -> void:
	if _dummy:
		queue_free()
	
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
		
		_:
			_default_jump_sfx_player.play()
	
	velocity = Vector2.UP.rotated(rotation) * jump_force
	move_and_slide()


func _physics_process(delta: float) -> void:
	_update_rotation()
	
	if _immovable:
		velocity = Vector2.ZERO
		return
	
	_apply_gravity(delta)
	move_and_slide()


func _apply_gravity(frame_delta: float) -> void:
	if not is_on_floor() and not _immovable:
		velocity.y += _gravity * frame_delta


func _update_rotation() -> void:
	if _rotation_stick_state and _rotation_stick_state.is_active:
		rotation = _rotation_stick_state.output_value.rotated(-PI/2).angle()
		return
	
	#rotation = get_global_mouse_position().angle_to_point(global_position) + PI / 2
	rotation = Input.get_vector("hero_rotate_left", "hero_rotate_right",
		"hero_rotate_up", "hero_rotate_down").rotated(-PI/2).angle()


func _on_flip_end(angle_delta: float) -> void:
	if angle_delta > PI:
		if angle_delta > PI * 3:
			double_frontfliped.emit()
			_cur_jump_type = JumpType.ULTRA
		else:
			frontfliped.emit()
			_cur_jump_type = JumpType.SUPER
	
	if angle_delta < -PI:
		if angle_delta < -PI * 3:
			double_backfliped.emit()
			_cur_jump_type = JumpType.ULTRA
		else:
			backfliped.emit()
			_cur_jump_type = JumpType.SUPER


func _input(event: InputEvent) -> void:
	if _immovable and event.is_action_pressed("hero_revive"):
		_cur_jump_type = JumpType.DEFAULT
		_immovable = false


enum JumpType {
	DEFAULT,
	SUPER,
	ULTRA,
}
