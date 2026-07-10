extends EnemyBase

var direction := Vector2.DOWN
var _time := 0.0

func _setup_enemy():
	health = Constants.ENEMY_TANK_HEALTH
	max_health = health
	speed = Constants.ENEMY_TANK_SPEED
	score_value = Constants.ENEMY_TANK_SCORE
	enemy_type = "tank"
	collision_shape.scale = Vector2(1.5, 1.5)


func _get_hp_per_wave() -> float:
	return Constants.ENEMY_TANK_HP_PER_WAVE


func _get_speed_per_wave() -> float:
	return Constants.ENEMY_TANK_SPEED_PER_WAVE


func _move(delta):
	_time += delta
	var sway = sin(_time * 1.5) * 50.0
	global_position.x += sway * delta
	global_position += direction * speed * delta
