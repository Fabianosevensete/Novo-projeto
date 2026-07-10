class_name StateMachine
extends Node

signal state_changed(current_state, previous_state)

@export var initial_state : String = ""
@export var debug_mode := false

var current_state : String = ""
var previous_state : String = ""
var _states := {}
var _active := false

func _ready():
	await owner.ready
	for child in get_children():
		if child is State:
			_states[child.name] = child
			child.state_machine = self
			child._ready()
	if initial_state.is_empty() and _states.size() > 0:
		initial_state = _states.keys()[0]
	if not initial_state.is_empty():
		_change_state(initial_state)
		_active = true

func _process(delta):
	if _active and current_state in _states:
		_states[current_state].update(delta)

func _physics_process(delta):
	if _active and current_state in _states:
		_states[current_state].physics_update(delta)

func _input(event):
	if _active and current_state in _states:
		_states[current_state].handle_input(event)

func change_state(new_state: String):
	if new_state == current_state:
		return
	if new_state not in _states:
		push_warning("State not found: ", new_state)
		return
	if debug_mode:
		print("StateMachine: ", owner.name, " ", current_state, " -> ", new_state)
	_change_state(new_state)

func _change_state(new_state: String):
	if _active and current_state in _states:
		_states[current_state].exit()
	previous_state = current_state
	current_state = new_state
	_states[current_state].enter()
	state_changed.emit(current_state, previous_state)

func get_state_node(state_name: String) -> State:
	return _states.get(state_name)
