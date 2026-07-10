extends Node2D

@onready var particles := $GPUParticles2D
@onready var flash := $Flash
@onready var shockwave := $Shockwave


func _ready():
	_generate_shockwave()
	particles.emitting = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "modulate:a", 0.0, 0.25)
	tween.tween_property(shockwave, "scale", Vector2(3, 3), 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(shockwave, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_finished)


func _generate_shockwave():
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for x in range(64):
		for y in range(64):
			var dx = x - 32
			var dy = y - 32
			var dist = sqrt(dx*dx + dy*dy)
			if dist >= 20 and dist <= 28:
				var alpha = 1.0 - abs(dist - 24) / 4.0
				image.set_pixel(x, y, Color(1, 1, 1, alpha * 0.6))
	shockwave.texture = ImageTexture.create_from_image(image)


func _finished():
	queue_free()
