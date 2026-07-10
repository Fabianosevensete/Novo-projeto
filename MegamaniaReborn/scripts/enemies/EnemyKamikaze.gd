extends EnemyBase

var _target_velocity := Vector2.ZERO

func _setup_enemy():
	health = Constants.ENEMY_KAMIKAZE_HEALTH
	max_health = health
	speed = Constants.ENEMY_KAMIKAZE_SPEED
	score_value = Constants.ENEMY_KAMIKAZE_SCORE
	enemy_type = "kamikaze"


func _move(delta):
	var player = _get_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		_target_velocity = direction * speed
	global_position += _target_velocity * delta


func _get_speed_per_wave() -> float:
	return Constants.ENEMY_KAMIKAZE_SPEED_PER_WAVE


func _get_player() -> Node2D:
	var player = get_tree().get_first_node_in_group(Constants.GROUPS.PLAYER)
	return player as Node2D
