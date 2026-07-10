extends GutTest

func before_all():
	_add_autoload("EventBus", "res://scripts/core/EventBus.gd")
	_add_autoload("ScoreManager", "res://scripts/core/ScoreManager.gd")

func _add_autoload(name: String, path: String):
	if not get_tree().root.has_node(name):
		var node = load(path).new()
		get_tree().root.add_child(node)
		node.name = name

func test_initial_state_is_menu():
	var gm = autofree(load("res://scripts/core/GameManager.gd").new())
	assert_eq(gm.current_state, gm.GameState.MENU, "Game should start in MENU state")


func test_change_state_playing():
	var gm = autofree(load("res://scripts/core/GameManager.gd").new())
	gm.change_state(gm.GameState.PLAYING)
	assert_eq(gm.current_state, gm.GameState.PLAYING, "State should be PLAYING")
	assert_eq(gm.previous_state, gm.GameState.MENU, "Previous state should be MENU")


func test_change_state_game_over():
	var gm = autofree(load("res://scripts/core/GameManager.gd").new())
	gm.change_state(gm.GameState.PLAYING)
	gm.change_state(gm.GameState.GAME_OVER)
	assert_eq(gm.current_state, gm.GameState.GAME_OVER, "State should be GAME_OVER")


func test_is_playing():
	var gm = autofree(load("res://scripts/core/GameManager.gd").new())
	assert_false(gm.is_playing(), "Should not be playing in MENU")
	gm.change_state(gm.GameState.PLAYING)
	assert_true(gm.is_playing(), "Should be playing after change")


func test_same_state_no_change():
	var gm = autofree(load("res://scripts/core/GameManager.gd").new())
	gm.change_state(gm.GameState.MENU)
	assert_eq(gm.previous_state, gm.GameState.MENU, "Previous should remain MENU when same state")
