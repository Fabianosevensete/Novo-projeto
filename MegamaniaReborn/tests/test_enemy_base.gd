extends GutTest


func before_all():
	if not get_tree().root.has_node("EventBus"):
		var eb = load("res://scripts/core/EventBus.gd").new()
		get_tree().root.add_child(eb)
		eb.name = "EventBus"
	if not get_tree().root.has_node("ScoreManager"):
		var sm = load("res://scripts/core/ScoreManager.gd").new()
		get_tree().root.add_child(sm)
		sm.name = "ScoreManager"
	if not get_tree().root.has_node("WaveManager"):
		var wm = load("res://scripts/core/WaveManager.gd").new()
		get_tree().root.add_child(wm)
		wm.name = "WaveManager"


func test_initial_health():
	var enemy = autofree(load("res://scripts/enemies/EnemyBase.gd").new())
	assert_eq(enemy.health, 1, "Default health should be 1")
	assert_eq(enemy.max_health, 1, "Default max health should be 1")


func test_take_damage_reduces_health():
	var enemy = autofree(load("res://scripts/enemies/EnemyBase.gd").new())
	enemy.take_damage(1)
	assert_eq(enemy.health, 0, "Health should be 0 after damage")


func test_take_damage_partial():
	var enemy = autofree(load("res://scripts/enemies/EnemyBase.gd").new())
	enemy.health = 10
	enemy.max_health = 10
	enemy.take_damage(3)
	assert_eq(enemy.health, 7, "Health should decrease by damage amount")


func test_wave_scaling_applies():
	var enemy = autofree(load("res://scripts/enemies/EnemyBase.gd").new())
	enemy._apply_wave_scaling()
	assert_gt(enemy.health, 0, "Wave scaling should not crash")


func test_enemy_type_default():
	var enemy = autofree(load("res://scripts/enemies/EnemyBase.gd").new())
	assert_eq(enemy.enemy_type, "base", "Default enemy type should be 'base'")
