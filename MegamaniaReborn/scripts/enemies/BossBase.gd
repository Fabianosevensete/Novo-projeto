class_name BossBase
extends Area2D

const Constants = preload("res://scripts/utils/Constants.gd")

var health := 50
var max_health := 50
var current_phase := 1
var speed := Constants.BOSS_SPEED
var score_value := Constants.BOSS_SCORE
var can_take_damage := false
var _time := 0.0
var _move_dir := 1.0
var _screen_size := Vector2.ZERO

var base_health := Constants.BOSS_BASE_HEALTH
var speed_mult := 1.0
var shoot_cooldown_mult := 1.0

@onready var sprite := $Sprite2D
@onready var weak_point := $WeakPoint
@onready var collision_shape := $CollisionShape2D
@onready var event_bus := get_node("/root/EventBus")
@onready var score_manager := get_node("/root/ScoreManager")


func _ready():
	_screen_size = get_viewport().get_visible_rect().size
	add_to_group(Constants.GROUPS.ENEMY)
	area_entered.connect(_on_area_entered)
	var wave = get_node_or_null("/root/WaveManager") if is_inside_tree() else null
	if wave:
		var wave_num = wave.current_wave
		max_health = base_health + (wave_num - 1) * Constants.BOSS_HEALTH_PER_WAVE
		health = max_health
		if event_bus:
			event_bus.boss_hp_changed.emit(health, max_health)
	_generate_texture()
	_enter_scene()


func _enter_scene():
	visible = false
	position = Vector2(_screen_size.x * 0.5, -100)
	can_take_damage = false
	var tween = create_tween()
	tween.tween_property(self, "position:y", 80, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(_on_entered)
	event_bus.screen_shake.emit(5.0, 0.5)


func _on_entered():
	visible = true
	can_take_damage = true
	_setup_phase()


func _setup_phase():
	pass


func _generate_texture():
	if not sprite:
		return
	var w = 96; var h = 64
	var image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color = Color(0.8, 0.1, 0.4, 1)
	for x in range(w):
		for y in range(h):
			var dx = x - w/2; var dy = y - h/2
			if _is_in_boss_shape(dx, dy, w, h):
				var c = color
				if abs(dx) < 4 and dy < 0:
					c = Color(1, 0.3, 0.6, 1)
				if dy > 15 and abs(dx) < 10:
					c = Color(0.3, 0.8, 1, 1)
				image.set_pixel(x, y, c)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture


func _is_in_boss_shape(dx: float, dy: float, w: int, h: int) -> bool:
	var outer = abs(dx) / 40.0 + abs(dy) / 28.0
	if outer <= 1.0: return true
	if dy >= 0 and abs(dx) <= 8 and dy <= 20: return true
	return false


func take_damage(amount: int = 1):
	if not can_take_damage:
		return
	health -= amount
	if health < 0:
		health = 0
	event_bus.boss_hp_changed.emit(health, max_health)
	_flash_hit()
	var new_phase = _calculate_phase()
	if new_phase != current_phase:
		current_phase = new_phase
		_on_phase_change()
	if health <= 0:
		_die()


func _calculate_phase() -> int:
	var pct = float(health) / float(max_health)
	if pct <= 0.25: return 4
	if pct <= 0.50: return 3
	if pct <= 0.75: return 2
	return 1


func _on_phase_change():
	can_take_damage = false
	event_bus.screen_shake.emit(10.0, 0.5)
	var tween = create_tween()
	sprite.modulate = Color.RED
	tween.tween_interval(Constants.BOSS_PHASE_TRANSITION_DELAY)
	tween.tween_callback(_finish_phase_transition)


func _finish_phase_transition():
	sprite.modulate = Color.WHITE
	can_take_damage = true
	_setup_phase()


func _flash_hit():
	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5, 1)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)


func _move(delta):
	_time += delta
	position.x += _move_dir * speed * speed_mult * delta
	if position.x > _screen_size.x - 100:
		_move_dir = -1.0
	elif position.x < 100:
		_move_dir = 1.0
	position.y = 80 + sin(_time * 0.5) * 20


func _die():
	can_take_damage = false
	event_bus.boss_died.emit(global_position)
	score_manager.add_score(score_value)
	_spawn_explosion()
	_spawn_rewards()
	queue_free()


func _spawn_explosion():
	for i in range(6):
		var scene = load("res://scenes/effects/Explosion.tscn")
		if scene:
			var explosion = scene.instantiate()
			explosion.global_position = global_position + Vector2(
				randf_range(-40, 40), randf_range(-30, 30))
			get_tree().current_scene.add_child(explosion)
	event_bus.screen_shake.emit(15.0, 0.8)


func _spawn_rewards():
	for i in range(5 + randi() % 3):
		var pickup_path = "res://scenes/effects/Pickup.tscn"
		var scene = load(pickup_path)
		if scene:
			var pickup = scene.instantiate()
			pickup.global_position = global_position + Vector2(
				randf_range(-50, 50), randf_range(-30, 30))
			var types = [
				Constants.PickupType.HEALTH,
				Constants.PickupType.SHIELD,
				Constants.PickupType.WEAPON_UP,
				Constants.PickupType.SCORE_MULTI,
				Constants.PickupType.SPEED_BOOST,
			]
			pickup.pickup_type = types[randi() % types.size()]
			get_tree().current_scene.add_child(pickup)


func _on_area_entered(area: Area2D):
	if area.is_in_group(Constants.GROUPS.PLAYER):
		if area.has_method("take_damage"):
			area.take_damage(2)
