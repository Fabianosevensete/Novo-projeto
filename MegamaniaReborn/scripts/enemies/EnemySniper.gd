extends EnemyBase

var _shoot_timer := 0.0

func _setup_enemy():
	health = Constants.ENEMY_SNIPER_HEALTH
	max_health = health
	speed = Constants.ENEMY_SNIPER_SPEED
	score_value = Constants.ENEMY_SNIPER_SCORE
	enemy_type = "sniper"
	_shoot_timer = randf_range(0.5, Constants.ENEMY_SNIPER_SHOOT_COOLDOWN)


func _move(delta):
	var player = _get_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		var distance = global_position.distance_to(player.global_position)
		if distance < Constants.ENEMY_SNIPER_PREFERRED_DISTANCE:
			global_position -= direction * speed * delta
		elif distance > Constants.ENEMY_SNIPER_PREFERRED_DISTANCE * 1.5:
			global_position += direction * speed * delta


func _process(delta):
	super._process(delta)
	_shoot_timer -= delta
	if _shoot_timer <= 0 and _get_player():
		_shoot()
		_shoot_timer = Constants.ENEMY_SNIPER_SHOOT_COOLDOWN


func _shoot():
	var player = _get_player()
	if not player:
		return
	var scene = load("res://scenes/bullets/BulletEnemy.tscn")
	if scene:
		var bullet = scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = (player.global_position - global_position).normalized()
		bullet.speed = Constants.ENEMY_SNIPER_BULLET_SPEED
		var parent_node = get_parent() if get_parent() else get_tree().current_scene
		parent_node.add_child(bullet)


func _get_hp_per_wave() -> float:
	return Constants.ENEMY_SNIPER_HP_PER_WAVE


func _apply_custom_scaling(wave: int):
	_shoot_timer = max(0.5, Constants.ENEMY_SNIPER_SHOOT_COOLDOWN + (wave - 1) * Constants.ENEMY_SNIPER_CD_PER_WAVE)


func _get_player() -> Node2D:
	var player = get_tree().get_first_node_in_group(Constants.GROUPS.PLAYER)
	return player as Node2D
