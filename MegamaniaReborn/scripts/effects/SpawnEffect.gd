extends Node2D

func _ready():
	var sprite = Sprite2D.new()
	sprite.centered = true
	add_child(sprite)
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for x in range(48):
		for y in range(48):
			var dx = x - 24
			var dy = y - 24
			var dist = sqrt(dx*dx + dy*dy)
			if dist >= 8 and dist <= 24:
				var alpha = 1.0 - (dist - 8) / 16.0
				var c = Color(0, 1, 1, alpha * 0.6)
				image.set_pixel(x, y, c)
	sprite.texture = ImageTexture.create_from_image(image)
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(2, 2), 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.finished.connect(queue_free)
