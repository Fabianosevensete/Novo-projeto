extends GutTest

func test_initial_wave_zero():
	var wm = autofree(load("res://scripts/core/WaveManager.gd").new())
	assert_eq(wm.current_wave, 0, "Wave should start at 0")


func test_start_waves_increments():
	var wm = autofree(load("res://scripts/core/WaveManager.gd").new())
	wm.start_waves()
	assert_eq(wm.current_wave, 1, "First wave should be 1")
	assert_true(wm.wave_active, "Wave should be active after start")


func test_enemy_composition():
	var wm = autofree(load("res://scripts/core/WaveManager.gd").new())
	wm.start_waves()
	assert_gt(wm.enemies_to_spawn.size(), 0, "Should have enemies to spawn")


func test_wave_difficulty_scales():
	var wm = autofree(load("res://scripts/core/WaveManager.gd").new())
	wm.start_waves()
	var first_wave_count = wm.enemies_to_spawn.size()
	wm._next_wave()
	var second_wave_count = wm.enemies_to_spawn.size()
	assert_gt(second_wave_count, first_wave_count, "Second wave should have more enemies")
