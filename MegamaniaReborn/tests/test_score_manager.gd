extends GutTest

func test_initial_score_is_zero():
	var sm = autofree(load("res://scripts/core/ScoreManager.gd").new())
	assert_eq(sm.score, 0, "Initial score should be 0")
	assert_eq(sm.combo_count, 0, "Initial combo should be 0")


func test_add_score_increases_score():
	var sm = autofree(load("res://scripts/core/ScoreManager.gd").new())
	sm.add_score(100)
	assert_eq(sm.score, 100, "Score should be 100")
	assert_eq(sm.combo_count, 1, "Combo should be 1")


func test_combo_multiplier():
	var sm = autofree(load("res://scripts/core/ScoreManager.gd").new())
	sm.add_score(100)
	sm.add_score(100)
	assert_eq(sm.score, 250, "Two kills with combo: 100 + (100 * 1.5) = 250")


func test_reset_score():
	var sm = autofree(load("res://scripts/core/ScoreManager.gd").new())
	sm.add_score(500)
	sm.reset_score()
	assert_eq(sm.score, 0, "Score should reset to 0")
	assert_eq(sm.combo_count, 0, "Combo should reset to 0")


func test_combo_timeout():
	var sm = autofree(load("res://scripts/core/ScoreManager.gd").new())
	sm.add_score(100)
	sm.add_score(100)
	sm.combo_timer = 0.0
	sm._process(0.1)
	assert_eq(sm.combo_count, 0, "Combo should timeout")
