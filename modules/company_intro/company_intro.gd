extends Sprite2D


signal playing_completed


@export var _autostart: bool
@export var _skip: bool

@export var _logo_out_animation_start_delay: float = 0.9
@export var _completion_delay: float = 0.3

@export_group("Components")
@export var _animation_player: AnimationPlayer


func play() -> void:
	_animation_player.play("in")
	await _animation_player.animation_finished
	
	await get_tree().create_timer(_logo_out_animation_start_delay).timeout
	
	_animation_player.play("out")
	await _animation_player.animation_finished
	
	await get_tree().create_timer(_completion_delay).timeout
	
	playing_completed.emit()


func _ready() -> void:
	if _skip:
		hide()
		
		playing_completed.emit()
		return
	
	if _autostart:
		play()
