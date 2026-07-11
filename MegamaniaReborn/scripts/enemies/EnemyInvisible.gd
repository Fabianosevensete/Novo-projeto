extends EnemyBase

var _target_velocity := Vector2.ZERO
var _cycle_timer := 0.0
var _is_visible_state := true

func _setup_enemy():
	health = Constants.ENEMY_INVISIBLE_HEALTH
	max_health = health
	speed = Constants.ENEMY_INVISIBLE_SPEED
	score_value = Constants.ENEMY_INVISIBLE_SCORE
	enemy_type = "invisible"
	_cycle_timer = Constants.ENEMY_INVISIBLE_VISIBLE_TIME


func _generate_texture():
	if _texture_generated or not sprite:
		return
	var image = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color = Color(0.6, 0.0, 1.0, 1)
	for x in range(20):
		for y in range(20):
			var dx = x - 10; var dy = y - 10
			if abs(dx) + abs(dy) <= 8:
				var c = color
				if abs(dx) + abs(dy) <= 3:
					c = Color(0.8, 0.3, 1.0, 1)
				image.set_pixel(x, y, c)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	_texture_generated = true


func _get_color() -> Color:
	return Color(0.6, 0.0, 1.0, 1)


func _process(delta):
	super._process(delta)
	_cycle_timer -= delta
	if _cycle_timer <= 0:
		_toggle_visibility()


func _toggle_visibility():
	_is_visible_state = not _is_visible_state
	if _is_visible_state:
		_cycle_timer = Constants.ENEMY_INVISIBLE_VISIBLE_TIME
		sprite.modulate = Color(1, 1, 1, 1)
		collision_shape.set_deferred("disabled", false)
	else:
		_cycle_timer = Constants.ENEMY_INVISIBLE_CYCLE - Constants.ENEMY_INVISIBLE_VISIBLE_TIME
		sprite.modulate = Color(1, 1, 1, 0.2)
		collision_shape.set_deferred("disabled", true)


func _move(delta):
	var player = _get_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		_target_velocity = direction * speed
	global_position += _target_velocity * delta


func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group(Constants.GROUPS.PLAYER) as Node2D
