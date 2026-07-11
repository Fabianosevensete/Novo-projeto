extends GutTest


func _create_test_scene() -> PackedScene:
	var node = Node2D.new()
	node.name = "TestObject"
	var scene = PackedScene.new()
	scene.pack(node)
	node.free()
	return scene


func test_register_creates_pool():
	var pm = autofree(load("res://scripts/core/PoolManager.gd").new())
	var scene = _create_test_scene()
	pm.register_scene(scene, "bullets", 5)
	assert_eq(pm.get_pool_size("bullets"), 5, "Pool should have 5 objects")


func test_get_object_returns_node():
	var pm = autofree(load("res://scripts/core/PoolManager.gd").new())
	var scene = _create_test_scene()
	pm.register_scene(scene, "bullets", 3)
	var obj = pm.get_object("bullets")
	assert_not_null(obj, "Should get an object from pool")
	assert_true(obj.visible, "Object should be visible after get")


func test_get_object_returns_null_for_unknown_pool():
	var pm = autofree(load("res://scripts/core/PoolManager.gd").new())
	var obj = pm.get_object("nonexistent")
	assert_null(obj, "Should return null for unknown pool")
	assert_push_error("Pool not found", "Should report pool not found")


func test_return_object_hides_it():
	var pm = autofree(load("res://scripts/core/PoolManager.gd").new())
	var scene = _create_test_scene()
	pm.register_scene(scene, "bullets", 3)
	var obj = pm.get_object("bullets")
	pm.return_object(obj, "bullets")
	assert_false(obj.visible, "Object should be hidden after return")


func test_get_pool_size_unknown():
	var pm = autofree(load("res://scripts/core/PoolManager.gd").new())
	assert_eq(pm.get_pool_size("unknown"), 0, "Unknown pool should have size 0")


func test_clear_all_empties_pools():
	var pm = autofree(load("res://scripts/core/PoolManager.gd").new())
	var scene = _create_test_scene()
	pm.register_scene(scene, "enemies", 2)
	pm.clear_all()
	assert_eq(pm.get_pool_size("enemies"), 0, "Pool should be empty after clear")


func test_pool_expands_when_exhausted():
	var pm = autofree(load("res://scripts/core/PoolManager.gd").new())
	var scene = _create_test_scene()
	pm.register_scene(scene, "bullets", 1)
	var obj1 = pm.get_object("bullets")
	var obj2 = pm.get_object("bullets")
	assert_not_null(obj2, "Pool should expand when empty")
	assert_eq(pm.get_pool_size("bullets"), 2, "Pool size should increase")
