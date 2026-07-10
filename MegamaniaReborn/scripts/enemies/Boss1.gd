extends BossBase

var _shoot_timer := 0.0
var _pattern_index := 0
var _drone_scene = null
var _drones := []


func _setup_phase():
	match current_phase:
		1: _shoot_timer = 1.0
		2: _shoot_timer = 0.8
		3: _shoot_timer = 0.6
		4: _shoot_timer = 0.4
	_shoot_timer *= randf_range(0.8, 1.2)


func _ready():
	super._ready()
	_drone_scene = load("res://scenes/enemies/EnemyKamikaze.tscn")


func take_damage(amount: int = 1):
	super.take_damage(amount)
	if current_phase >= 3 and _drones.is_empty() and can_take_damage:
		_spawn_drones()


func _process(delta):
	if not can_take_damage:
		return
	_move(delta)
	_shoot_timer -= delta
	if _shoot_timer <= 0:
		_execute_attack()
		_shoot_timer = _get_attack_cooldown()


func _get_attack_cooldown() -> float:
	var base: float
	match current_phase:
		1: base = 1.5
		2: base = 1.2
		3: base = 0.9
		4: base = 0.6
		_: base = 1.0
	return base * shoot_cooldown_mult


func _execute_attack():
	match current_phase:
		1: _attack_aimed()
		2: _attack_aimed() if _pattern_index % 2 == 0 else _attack_burst()
		3: _attack_burst() if _pattern_index % 2 == 0 else _attack_spread()
		4: _attack_spiral()
	_pattern_index += 1


func _attack_aimed():
	var player = _get_player()
	if not player:
		return
	var scene = load("res://scenes/bullets/BossBullet.tscn")
	if not scene:
		return
	var bullet = scene.instantiate()
	bullet.global_position = global_position + Vector2(0, 30)
	var dir = (player.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.speed = 250.0
	get_tree().current_scene.add_child(bullet)


func _attack_burst():
	for i in range(Constants.BOSS_BURST_COUNT):
		var scene = load("res://scenes/bullets/BossBullet.tscn")
		if not scene:
			return
		var bullet = scene.instantiate()
		bullet.global_position = global_position + Vector2(0, 30)
		var player = _get_player()
		if not player:
			return
		var base_dir = (player.global_position - global_position).normalized()
		var spread = (i - 1) * 0.15
		bullet.direction = base_dir.rotated(spread)
		bullet.speed = 250.0
		get_tree().current_scene.add_child(bullet)


func _attack_spread():
	var scene = load("res://scenes/bullets/BossBullet.tscn")
	if not scene:
		return
	var count = Constants.BOSS_SPREAD_COUNT
	for i in range(count):
		var bullet = scene.instantiate()
		bullet.global_position = global_position + Vector2(0, 30)
		var angle = (float(i) / float(count)) * TAU - PI * 0.5
		bullet.direction = Vector2.RIGHT.rotated(angle)
		bullet.speed = 180.0
		get_tree().current_scene.add_child(bullet)


func _attack_spiral():
	var scene = load("res://scenes/bullets/BossBullet.tscn")
	if not scene:
		return
	var count = 6
	var base_angle = _time * 2.0
	for i in range(count):
		var bullet = scene.instantiate()
		bullet.global_position = global_position + Vector2(0, 30)
		var angle = base_angle + (float(i) / float(count)) * TAU
		bullet.direction = Vector2.RIGHT.rotated(angle)
		bullet.speed = 200.0
		get_tree().current_scene.add_child(bullet)


func _spawn_drones():
	for i in range(Constants.BOSS_DRONE_COUNT):
		var drone = _drone_scene.instantiate()
		drone.global_position = global_position + Vector2(
			(i - 1) * 40, 40)
		drone.speed = 300.0
		drone.enemy_type = "drone"
		drone.score_value = 50
		drone.health = 1
		get_tree().current_scene.add_child(drone)
		_drones.append(drone)


func _get_player() -> Node2D:
	var player = get_tree().get_first_node_in_group(Constants.GROUPS.PLAYER)
	return player as Node2D
