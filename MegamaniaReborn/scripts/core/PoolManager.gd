extends Node

var _pools := {}

func register_scene(scene: PackedScene, pool_name: String, initial_size: int = 10):
	var pool := []
	for i in range(initial_size):
		var instance = scene.instantiate()
		instance.visible = false
		add_child(instance)
		pool.append(instance)
	_pools[pool_name] = pool


func get_object(pool_name: String) -> Node:
	if pool_name not in _pools:
		push_error("Pool not found: ", pool_name)
		return null
	var pool = _pools[pool_name]
	for obj in pool:
		if not obj.visible:
			obj.visible = true
			return obj
	var scene = null
	if pool.size() > 0:
		scene = pool[0].duplicate()
	if scene:
		scene.visible = true
		add_child(scene)
		pool.append(scene)
		return scene
	return null


func return_object(obj: Node, pool_name: String):
	if pool_name not in _pools:
		push_error("Pool not found: ", pool_name)
		obj.queue_free()
		return
	obj.visible = false
	if obj is Node2D:
		obj.position = Vector2.ZERO
	if obj is RigidBody2D:
		obj.linear_velocity = Vector2.ZERO
		obj.angular_velocity = 0


func get_pool_size(pool_name: String) -> int:
	if pool_name in _pools:
		return _pools[pool_name].size()
	return 0


func clear_all():
	for pool_name in _pools:
		for obj in _pools[pool_name]:
			if is_instance_valid(obj):
				obj.queue_free()
	_pools.clear()
