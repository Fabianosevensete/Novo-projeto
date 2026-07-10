extends GutTest

func before_all():
	if not get_tree().root.has_node("EventBus"):
		var eb = load("res://scripts/core/EventBus.gd").new()
		get_tree().root.add_child(eb)
		eb.name = "EventBus"

func test_player_initial_health():
	var player = autofree(load("res://scripts/player/Player.gd").new())
	assert_eq(player.health, 3, "Player should start with 3 health")
	assert_false(player.invulnerable, "Player should not start invulnerable")


func test_player_take_damage():
	var player = autofree(load("res://scripts/player/Player.gd").new())
	player.take_damage(1)
	assert_eq(player.health, 2, "Health should decrease by 1")
	assert_true(player.invulnerable, "Player should be invulnerable after hit")


func test_player_invulnerable_blocks_damage():
	var player = autofree(load("res://scripts/player/Player.gd").new())
	player.take_damage(1)
	player.take_damage(1)
	assert_eq(player.health, 2, "Damage should be blocked during invulnerability")


func test_player_death():
	var player = autofree(load("res://scripts/player/Player.gd").new())
	player.take_damage(3)
	assert_eq(player.health, 0, "Health should be 0")
	assert_false(player.visible, "Player should be invisible after death")


func test_player_dash():
	var player = autofree(load("res://scripts/player/Player.gd").new())
	player._perform_dash()
	assert_true(player.dashing, "Player should be dashing")
	assert_false(player.can_dash, "Player should not be able to dash again")
	assert_true(player.invulnerable, "Player should be invulnerable during dash")
