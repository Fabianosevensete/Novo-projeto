extends EnemyBase

const Constants = preload("res://scripts/utils/Constants.gd")

var _target_velocity := Vector2.ZERO
var _shield_hp := Constants.ENEMY_SHIELD_HP
var _shield_broken := false
var _recharge_timer := 0.0
var _recharge_time := Constants.ENEMY_SHIELD_RECHARGE_TIME
var _shield_node: Area2D = null
var _shield_sprite: Sprite2D = null

func _setup_enemy():
	health = Constants.ENEMY_SHIELD_HEALTH
	max_health = health
	speed = Constants.ENEMY_SHIELD_SPEED
	score_value = Constants.ENEMY_SHIELD_SCORE
	enemy_type = "shield"
	_create_shield()


func _create_shield():
	_shield_node = Area2D.new()
	_shield_node.name = "ShieldArea"
	_shield_node.collision_layer = 0
	_shield_node.collision_mask = 2
	_shield_sprite = Sprite2D.new()
	_shield_sprite.name = "ShieldSprite"
	var image = Image.create(28, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var shield_color = Color(0.3, 0.6, 1.0, 0.6)
	for x in range(28):
		for y in range(12):
			var dx = x - 14; var dy = y - 6
			if abs(dx) <= 12 and abs(dy) <= 4:
				image.set_pixel(x, y, shield_color)
	var texture = ImageTexture.create_from_image(image)
	_shield_sprite.texture = texture
	_shield_sprite.position = Vector2(0, -16)
	_shield_node.add_child(_shield_sprite)
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(26, 10)
	shape.shape = rect
	shape.position = Vector2(0, -16)
	_shield_node.add_child(shape)
	add_child(_shield_node)
	_shield_node.area_entered.connect(_on_shield_hit)


func _generate_texture():
	if _texture_generated or not sprite:
		return
	var image = Image.create(22, 22, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color = Color(1.0, 0.6, 0.0, 1)
	for x in range(22):
		for y in range(22):
			var dx = x - 11; var dy = y - 11
			if dx*dx + dy*dy <= 100:
				var c = color
				if dx*dx + dy*dy <= 25:
					c = Color(1.0, 0.8, 0.2, 1)
				image.set_pixel(x, y, c)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	_texture_generated = true


func _get_color() -> Color:
	return Color(1.0, 0.6, 0.0, 1)


func _process(delta):
	super._process(delta)
	if _shield_broken:
		_recharge_timer -= delta
		if _recharge_timer <= 0:
			_recharge_shield()


func _move(delta):
	var player = _get_player()
	if player:
		var direction = (player.global_position - global_position).normalized()
		if _shield_broken:
			direction = -direction
		_target_velocity = direction * speed
	global_position += _target_velocity * delta


func _on_shield_hit(area: Area2D):
	if _shield_broken or not area.is_in_group(Constants.GROUPS.PLAYER_BULLET):
		return
	_shield_hp -= 1
	if _shield_node:
		_shield_node.modulate = Color(1, 1, 1, 0.3) if _shield_hp <= 1 else Color.WHITE
	if _shield_hp <= 0:
		_break_shield()


func _break_shield():
	_shield_broken = true
	_recharge_timer = _recharge_time
	if _shield_node:
		_shield_node.visible = false


func _recharge_shield():
	_shield_broken = false
	_shield_hp = Constants.ENEMY_SHIELD_HP
	if _shield_node:
		_shield_node.visible = true
		_shield_node.modulate = Color.WHITE


func take_damage(amount: int = 1):
	if not _shield_broken:
		return
	super.take_damage(amount)


func _get_hp_per_wave() -> float:
	return Constants.ENEMY_SHIELD_HP_PER_WAVE


func _apply_custom_scaling(wave: int):
	_recharge_time = max(2.0, Constants.ENEMY_SHIELD_RECHARGE_TIME + (wave - 1) * Constants.ENEMY_SHIELD_CD_PER_WAVE)


func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group(Constants.GROUPS.PLAYER) as Node2D
