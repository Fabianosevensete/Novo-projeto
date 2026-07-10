extends EnemyBase

var _target_velocity := Vector2.ZERO

func _setup_enemy():
	health = Constants.ENEMY_DIVIDER_HEALTH
	max_health = health
	speed = Constants.ENEMY_DIVIDER_SPEED
	score_value = Constants.ENEMY_DIVIDER_SCORE
	enemy_type = "divider"
	collision_shape.scale = Vector2(1.2, 1.2)


func _generate_texture():
	if _texture_generated or not sprite:
		return
	var image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color = Color(0.5, 1.0, 0.0, 1)
	for x in range(28):
		for y in range(28):
			var dx = x - 14; var dy = y - 14
			var diamond = abs(dx) * 0.7 + abs(dy) * 0.7
			if diamond <= 12:
				var c = color
				if diamond < 4: c = Color(0.8, 1.0, 0.3, 1)
				image.set_pixel(x, y, c)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	_texture_generated = true


func _get_color() -> Color:
	return Color(0.5, 1.0, 0.0, 1)


func _move(delta):
	var player = _get_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		_target_velocity = direction * speed
	global_position += _target_velocity * delta


func _die():
	if enemy_type == "divider":
		_spawn_children()
	super._die()


func _spawn_children():
	var scene_path = "res://scenes/enemies/EnemyDivider.tscn"
	var scene = load(scene_path)
	if not scene:
		return
	for i in range(2):
		var child = scene.instantiate()
		child.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		child.enemy_type = "divider_child"
		child.health = 1
		child.max_health = 1
		child.speed = Constants.ENEMY_KAMIKAZE_SPEED
		child.score_value = Constants.ENEMY_DIVIDER_CHILD_SCORE
		child.collision_shape.scale = Vector2(0.6, 0.6)
		var parent_node = get_parent() if get_parent() else get_tree().current_scene
		parent_node.add_child(child)


func _get_hp_per_wave() -> float:
	return Constants.ENEMY_DIVIDER_HP_PER_WAVE


func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group(Constants.GROUPS.PLAYER) as Node2D
