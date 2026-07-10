extends CanvasLayer

var _color_rect: ColorRect
var _animating := false


func _ready():
	_color_rect = ColorRect.new()
	_color_rect.color = Color.BLACK
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_color_rect)
	_color_rect.anchors_preset = Control.PRESET_FULL_RECT
	_color_rect.visible = false


func fade_in(duration: float = 0.2) -> Signal:
	_color_rect.visible = true
	_color_rect.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(_color_rect, "modulate", Color.WHITE, duration).set_ease(Tween.EASE_OUT)
	return tween.finished


func fade_out(duration: float = 0.3):
	_color_rect.visible = true
	_color_rect.modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property(_color_rect, "modulate", Color(1, 1, 1, 0), duration).set_ease(Tween.EASE_IN)
	await tween.finished
	_color_rect.visible = false
