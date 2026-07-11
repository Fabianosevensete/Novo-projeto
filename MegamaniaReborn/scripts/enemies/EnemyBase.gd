class_name EnemyBase
extends Area2D

const Constants = preload("res://scripts/utils/Constants.gd")

var health := 1
var max_health := 1
var speed := 100.0
var score_value := 100
var enemy_type := "base"
var damage_on_contact := 1
var is_minion := false
var _texture_generated := false

@onready var sprite := $Sprite2D
@onready var collision_shape := $CollisionShape2D
@onready var event_bus := get_node("/root/EventBus")
@onready var score_manager := get_node("/root/ScoreManager")


func _ready():
	add_to_group(Constants.GROUPS.ENEMY)
	area_entered.connect(_on_area_entered)
	_generate_texture()
	_setup_enemy()
	_apply_wave_scaling()
	_spawn_effect()


func _apply_wave_scaling():
	var wm = get_node_or_null("/root/WaveManager") if is_inside_tree() else null
	var wave = wm.current_wave if wm else 1
	if wave <= 1:
		return
	var hp_scale = _get_hp_per_wave()
	if hp_scale > 0:
		var extra = floor((wave - 1) * hp_scale)
		health += extra
		max_health += extra
	var speed_scale = _get_speed_per_wave()
	if speed_scale > 0:
		speed += (wave - 1) * speed_scale
	_apply_custom_scaling(wave)


func _get_hp_per_wave() -> float:
	return 0.0


func _get_speed_per_wave() -> float:
	return 0.0


func _apply_custom_scaling(_wave: int):
	pass


func _spawn_effect():
	var scene = load("res://scripts/effects/SpawnEffect.gd")
	if scene:
		var effect = scene.new()
		effect.global_position = global_position
		add_child(effect)


func _generate_texture():
	if _texture_generated or not sprite:
		return
	var image = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color = _get_color()
	for x in range(24):
		for y in range(24):
			var dx = x - 12
			var dy = y - 12
			if abs(dx) + abs(dy) <= 10:
				image.set_pixel(x, y, color)
			if abs(dx) + abs(dy) <= 5:
				image.set_pixel(x, y, color * 1.3)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	_texture_generated = true


func _get_color() -> Color:
	match enemy_type:
		"kamikaze": return Color(1, 0.3, 0.1, 1)
		"sniper": return Color(1, 0, 1, 1)
		"tank": return Color(0.2, 0.5, 1, 1)
	return Color.WHITE


func _setup_enemy():
	pass


func _process(delta):
	_move(delta)
	_check_out_of_bounds()


func _move(_delta: float):
	pass


func take_damage(amount: int = 1):
	health -= amount
	_flash_hit()
	if health <= 0:
		_die()


func _flash_hit():
	if sprite:
		sprite.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		if event_bus:
			event_bus.screen_shake.emit(Constants.SCREEN_SHAKE_INTENSITY * 0.5, 0.15)


func _die():
	if not is_minion:
		if event_bus:
			event_bus.enemy_killed.emit(enemy_type, global_position, score_value)
		if score_manager:
			score_manager.add_score(score_value)
		_try_drop_pickup()
		_show_score_popup()
	_spawn_explosion()
	queue_free()


func _show_score_popup():
	if not is_inside_tree():
		return
	var scene = load("res://scripts/effects/FloatingText.gd")
	if scene and get_tree() and get_tree().current_scene:
		var ft = scene.new()
		ft.global_position = global_position
		get_tree().current_scene.add_child(ft)
		ft.show_text("+" + str(score_value), global_position, Color(1, 1, 0, 1), 16)


func _try_drop_pickup():
	var drop_chance = Constants.PICKUP_DROP_CHANCE_TANK if enemy_type == "tank" else Constants.PICKUP_DROP_CHANCE_BASE
	if randf() > drop_chance:
		return
	var types = [
		Constants.PickupType.HEALTH,
		Constants.PickupType.SHIELD,
		Constants.PickupType.WEAPON_UP,
		Constants.PickupType.SCORE_MULTI,
		Constants.PickupType.SPEED_BOOST,
	]
	var pickup_type = types[randi() % types.size()]
	var scene = load("res://scenes/effects/Pickup.tscn")
	if scene:
		var pickup = scene.instantiate()
		pickup.pickup_type = pickup_type
		pickup.global_position = global_position
		var parent_node = get_parent() if get_parent() else (_get_current_scene())
		if parent_node:
			parent_node.add_child(pickup)



func _spawn_explosion():
	var scene = load("res://scenes/effects/Explosion.tscn")
	if scene:
		var explosion = scene.instantiate()
		explosion.global_position = global_position
		var parent_node = get_parent() if get_parent() else (_get_current_scene())
		if parent_node:
			parent_node.add_child(explosion)


func _get_current_scene():
	if not is_inside_tree():
		return null
	return get_tree().current_scene

func _check_out_of_bounds():
	var viewport = get_viewport()
	if not viewport:
		return
	var view_size = viewport.get_visible_rect().size
	var margin = 200.0
	if global_position.x < -margin or global_position.x > view_size.x + margin or \
	   global_position.y < -margin or global_position.y > view_size.y + margin:
		_die()


func _on_area_entered(area: Area2D):
	if area.is_in_group(Constants.GROUPS.PLAYER):
		_die()
