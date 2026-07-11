extends EnemyBase

var _spawn_timer := 0.0
var _direction := -1.0
var _screen_size := Vector2.ZERO

func _setup_enemy():
	health = Constants.ENEMY_INVOKER_HEALTH
	max_health = health
	speed = Constants.ENEMY_INVOKER_SPEED
	score_value = Constants.ENEMY_INVOKER_SCORE
	enemy_type = "invoker"
	_screen_size = get_viewport().get_visible_rect().size
	_spawn_timer = Constants.ENEMY_INVOKER_SPAWN_INTERVAL


func _generate_texture():
	if _texture_generated or not sprite:
		return
	var image = Image.create(30, 30, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color = Color(0.0, 0.4, 1.0, 1)
	for x in range(30):
		for y in range(30):
			var dx = x - 15; var dy = y - 15
			var hex = max(abs(dx) * 0.9 + abs(dy) * 0.5, abs(dx) * 0.5 + abs(dy) * 0.9)
			if hex <= 12:
				var c = color
				if hex < 5: c = Color(0.3, 0.7, 1.0, 1)
				image.set_pixel(x, y, c)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	_texture_generated = true


func _get_color() -> Color:
	return Color(0.0, 0.4, 1.0, 1)


func _process(delta):
	super._process(delta)
	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_spawn_minion()
		_spawn_timer = Constants.ENEMY_INVOKER_SPAWN_INTERVAL


func _move(delta):
	position.x += _direction * speed * delta
	if position.x > _screen_size.x - 80:
		_direction = -1.0
	elif position.x < 80:
		_direction = 1.0
	position.y = min(position.y + 5 * delta, 120)


func _get_hp_per_wave() -> float:
	return Constants.ENEMY_INVOKER_HP_PER_WAVE


func _apply_custom_scaling(wave: int):
	_spawn_timer = max(1.0, Constants.ENEMY_INVOKER_SPAWN_INTERVAL + (wave - 1) * Constants.ENEMY_INVOKER_SPAWN_CD_PER_WAVE)


func _spawn_minion():
	var scene = load("res://scenes/enemies/EnemyKamikaze.tscn")
	if not scene:
		return
	var minion = scene.instantiate()
	minion.global_position = global_position + Vector2(randf_range(-20, 20), 20)
	minion.speed = Constants.ENEMY_KAMIKAZE_SPEED * 1.2
	minion.score_value = 50
	minion.is_minion = true
	var parent_node = get_parent() if get_parent() else get_tree().current_scene
	parent_node.add_child(minion)
