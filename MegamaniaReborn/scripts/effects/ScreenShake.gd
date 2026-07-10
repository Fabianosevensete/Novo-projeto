extends Camera2D

var _shake_intensity := 0.0
var _shake_duration := 0.0
var _shake_timer := 0.0
var _original_offset := Vector2.ZERO

@onready var event_bus := get_node("/root/EventBus")


func _ready():
	_original_offset = offset
	event_bus.screen_shake.connect(_on_shake)


func _on_shake(intensity: float, duration: float):
	_shake_intensity = max(_shake_intensity, intensity)
	_shake_duration = max(_shake_duration, duration)
	_shake_timer = _shake_duration


func _process(delta):
	if _shake_timer > 0:
		_shake_timer -= delta
		var decay = _shake_timer / _shake_duration
		var current_intensity = _shake_intensity * decay
		offset = _original_offset + Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
	else:
		offset = _original_offset
		_shake_intensity = 0.0
