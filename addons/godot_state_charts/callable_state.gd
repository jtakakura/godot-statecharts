@tool
@icon("callable.svg")
class_name CallableState
extends AtomicState

## Node that this state will call.
@export_node_path("Target Node") var target_node: NodePath:
	set(value):
		target_node = value
		update_configuration_warnings()

## Method that this state will call in the specified object.
@export var method: StringName = ""

## Bound arguments 
@export var arguments: Array

## Flag to call the method in deferred mode or not
@export var deferred_mode: bool = false

var _callable: Callable

func _ready():
	var node = get_node_or_null(target_node)

	if not is_instance_valid(node):
		push_error("The specified node is invalid. This node will not work.")

	_callable = Callable(node, method).bindv(arguments)

	if not _callable.is_valid():
		push_error("The specified method or arguments are invalid. This node will not work.")

func _state_enter(expect_transition: bool = false):
	super(expect_transition)

	if not (is_instance_valid(_callable) and _callable.is_valid()):
		return

	if deferred_mode:
		_callable.call_deferred()
	else:
		_callable.call()

func _get_configuration_warnings():
	var warnings = super._get_configuration_warnings()

	if target_node.is_empty():
		warnings.append("No target node is set.")
	elif get_node_or_null(target_node) == null:
		warnings.append("The target node path is invalid.")

	return warnings
