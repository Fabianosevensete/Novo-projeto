extends Node

const Constants = preload("res://scripts/utils/Constants.gd")

var current_wave := 0
var enemies_spawned := 0
var enemies_alive := 0
var wave_active := false
var spawn_timer := 0.0
var spawn_interval := 1.0
var enemies_to_spawn := []
var _is_initialized := false
var _is_boss_wave := false
var _boss_alive := false
var _mode := Constants.GameMode.ARCADE
var _world: Node = null

@onready var event_bus := get_node("/root/EventBus")
@onready var game_manager := get_node("/root/GameManager")


func _ready():
	if event_bus:
		event_bus.enemy_killed.connect(_on_enemy_killed)
		event_bus.boss_died.connect(_on_boss_died)
		event_bus.game_state_changed.connect(_on_game_state_changed)
	_world = get_tree().root.find_child("GameWorld", true, false)
	if not _world:
		_world = get_tree().root
	_is_initialized = true


func _on_game_state_changed(new_state: int, _prev: int):
	if new_state == game_manager.GameState.PLAYING:
		_mode = game_manager.game_mode
	elif new_state == game_manager.GameState.MENU:
		stop_waves()


func start_waves():
	current_wave = 0
	_world = get_tree().root.find_child("GameWorld", true, false)
	if not _world:
		_world = get_tree().root
	_next_wave()


func stop_waves():
	wave_active = false


func _next_wave():
	current_wave += 1
	var boss_interval = Constants.MODE_BOSS_INTERVAL[_mode]
	_is_boss_wave = boss_interval > 0 and current_wave % boss_interval == 0
	enemies_spawned = 0
	enemies_alive = 0
	_boss_alive = false
	wave_active = true
	spawn_timer = Constants.WAVE_PREP_TIME
	if event_bus:
		event_bus.wave_started.emit(current_wave)
	if _is_boss_wave:
		enemies_to_spawn.clear()
	elif Constants.MODE_HAS_ENEMIES[_mode]:
		_compose_wave()
	else:
		enemies_to_spawn.clear()


func _compose_wave():
	enemies_to_spawn.clear()
	var w = current_wave
	var total = Constants.BASE_ENEMIES_PER_WAVE + (w - 1) * Constants.ENEMIES_PER_WAVE_INCREMENT
	var kamikaze_count = ceil(total * 0.35)
	var sniper_count = max(1, ceil(total * 0.2))
	var tank_count = max(0, ceil(total * 0.1))
	var divider_count = max(0, floor(total * 0.12))
	var invisible_count = max(0, floor(total * 0.1))
	var shield_count = max(0, floor(total * 0.08))
	var invoker_count = max(0, floor(total * 0.05))
	var filler = total - (kamikaze_count + sniper_count + tank_count + divider_count + invisible_count + shield_count + invoker_count)
	if filler > 0:
		kamikaze_count += filler
	for i in range(kamikaze_count):
		enemies_to_spawn.append("kamikaze")
	for i in range(sniper_count):
		enemies_to_spawn.append("sniper")
	for i in range(tank_count):
		enemies_to_spawn.append("tank")
	for i in range(divider_count):
		enemies_to_spawn.append("divider")
	for i in range(invisible_count):
		enemies_to_spawn.append("invisible")
	for i in range(shield_count):
		enemies_to_spawn.append("shield")
	for i in range(invoker_count):
		enemies_to_spawn.append("invoker")
	enemies_to_spawn.shuffle()
	spawn_interval = max(Constants.MIN_SPAWN_INTERVAL, Constants.SPAWN_INTERVAL_BASE - (current_wave - 1) * Constants.SPAWN_INTERVAL_DECAY)


func _process(delta):
	if not _is_initialized:
		return
	if not wave_active or not game_manager.is_playing():
		return
	if _is_boss_wave:
		_process_boss_wave()
	elif Constants.MODE_HAS_ENEMIES[_mode] and enemies_to_spawn.size() > 0:
		_process_normal_wave(delta)


func _process_normal_wave(delta):
	if enemies_spawned >= enemies_to_spawn.size() and enemies_alive <= 0:
		wave_active = false
		if event_bus:
			event_bus.wave_cleared.emit(current_wave)
		_next_wave()
		return
	if enemies_spawned < enemies_to_spawn.size():
		spawn_timer -= delta
		if spawn_timer <= 0:
			_spawn_enemy()


func _process_boss_wave():
	if not _boss_alive and spawn_timer > 0:
		spawn_timer -= get_process_delta_time()
		if spawn_timer <= 0:
			_spawn_boss()
	elif not _boss_alive:
		_spawn_boss()


func _spawn_boss():
	if _boss_alive:
		return
	var scene = load("res://scenes/enemies/Boss1.tscn")
	if not scene:
		return
	var boss = scene.instantiate()
	if _mode == Constants.GameMode.BOSS_RUSH:
		boss.base_health = Constants.BOSS_BASE_HEALTH + current_wave * Constants.BOSS_RUSH_HP_PER_WAVE
		boss.speed_mult = 1.0 + current_wave * Constants.BOSS_RUSH_SPEED_MULT_PER_WAVE
		boss.shoot_cooldown_mult = max(0.35, 1.0 + current_wave * Constants.BOSS_RUSH_CD_MULT_PER_WAVE)
	_world.add_child(boss)
	_boss_alive = true
	if event_bus:
		event_bus.boss_spawned.emit(boss)


func _spawn_enemy():
	if enemies_spawned >= enemies_to_spawn.size():
		return
	var type = enemies_to_spawn[enemies_spawned]
	enemies_spawned += 1
	spawn_timer = spawn_interval
	var enemy_scene_path = "res://scenes/enemies/Enemy" + type.capitalize() + ".tscn"
	var scene = load(enemy_scene_path)
	if scene:
		var enemy = scene.instantiate()
		enemy.enemy_type = type
		var spawn_pos = _get_spawn_position()
		enemy.global_position = spawn_pos
		_world.add_child(enemy)
		enemies_alive += 1
		if event_bus:
			event_bus.enemy_spawned.emit(enemy)


func _get_spawn_position() -> Vector2:
	var viewport = get_viewport()
	var view_size = viewport.get_visible_rect().size
	var margin = Constants.SPAWN_MARGIN
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(-margin, view_size.x + margin), -margin)
		1: return Vector2(view_size.x + margin, randf_range(-margin, view_size.y + margin))
		2: return Vector2(randf_range(-margin, view_size.x + margin), view_size.y + margin)
		3: return Vector2(-margin, randf_range(-margin, view_size.y + margin))
	return Vector2.ZERO


func _on_enemy_killed(_enemy_type, _position, _score_value):
	enemies_alive -= 1


func _on_boss_died(_position):
	_boss_alive = false
	wave_active = false
	if event_bus:
		event_bus.wave_cleared.emit(current_wave)
	_next_wave()
