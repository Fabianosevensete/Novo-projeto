extends ParallaxBackground

var _speed := Vector2(15.0, 8.0)
var _star_count := [80, 50, 25, 12]
var _star_colors := [
	Color(0.4, 0.4, 0.8, 0.3),
	Color(0.6, 0.6, 1.0, 0.5),
	Color(1.0, 1.0, 1.0, 0.7),
	Color(1.0, 0.8, 0.2, 0.8),
]

var _layers := []


func _ready():
	for child in get_children():
		if child is ParallaxLayer:
			_layers.append(child)
	for i in range(_layers.size()):
		var layer = _layers[i] as ParallaxLayer
		var scale_factor = 1.0 - (float(i) / float(max(_layers.size(), 1)))
		layer.motion_scale = Vector2(scale_factor * 0.4, scale_factor * 0.2)
		var texture_rect = layer.get_child(0) if layer.get_child_count() > 0 else null
		if texture_rect and texture_rect is TextureRect:
			_generate_stars_texture(texture_rect, _star_count[i], _star_colors[i])


func _generate_stars_texture(texture_rect: TextureRect, count: int, base_color: Color):
	var size = 1024
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(texture_rect.name + str(count))
	for i in range(count):
		var x = rng.randi() % size
		var y = rng.randi() % size
		var brightness = rng.randf_range(0.3, 1.0)
		var star_color = Color(
			base_color.r * brightness,
			base_color.g * brightness,
			base_color.b * brightness,
			base_color.a * brightness
		)
		var star_size = rng.randi() % 2 + 1
		for sx in range(star_size):
			for sy in range(star_size):
				var px = x + sx
				var py = y + sy
				if px < size and py < size:
					image.set_pixel(px, py, star_color)
	var texture = ImageTexture.create_from_image(image)
	texture_rect.texture = texture


func _process(delta):
	scroll_offset += _speed * delta
