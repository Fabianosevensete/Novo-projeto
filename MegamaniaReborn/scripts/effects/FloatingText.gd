extends Node2D

var _label: Label


func _ready():
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 18)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)


func show_text(text: String, position: Vector2, color: Color = Color.WHITE, size: int = 18):
	_label.text = text
	_label.add_theme_color_override("font_color", color)
	_label.add_theme_font_size_override("font_size", size)
	global_position = position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(_label, "modulate", Color(1, 1, 1, 0), 0.8).set_delay(0.2)
	tween.finished.connect(queue_free)
