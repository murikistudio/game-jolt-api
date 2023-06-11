extends Control


# Constants
const CONTROL_RECT_MIN_SIZE := Vector2(0, 32)


# Variables
@onready var _text_edit_output: TextEdit = find_child("TextEditOutput")
@onready var _container_inputs: Container = find_child("ContainerInputs")
@onready var _global := []
@onready var _endpoints := [
	{
		"name": "Global",
		"section": true,
	},
	{
		"name": "global",
		"global": true,
		"params": [
			{
				"name": "game_id",
				"value": GameJolt.game_id,
				"object": GameJolt,
				"property": "game_id",
			},
			{
				"name": "private_key",
				"value": GameJolt.private_key,
				"object": GameJolt,
				"property": "private_key",
				"secret": true,
			},
			{
				"name": "user_name",
				"value": GameJolt.get_user_name(),
				"object": GameJolt,
				"property": "user_name",
			},
			{
				"name": "user_token",
				"value": GameJolt.get_user_token(),
				"object": GameJolt,
				"property": "user_token",
				"secret": true,
			},
		],
	},

	# Users
	{
		"name": "Users",
		"section": true,
	},
	{
		"name": "users_fetch",
		"endpoint": true,
		"params": [
			{
				"name": "user_name",
				"value": "",
				"optional": true,
			},
			{
				"name": "user_ids",
				"value": [],
				"optional": true,
			},
		],
	},
	{
		"name": "users_auth",
		"endpoint": true,
	},

	# Sessions
	{
		"name": "Sessions",
		"section": true,
	},
	{
		"name": "sessions_open",
		"endpoint": true,
	},
	{
		"name": "sessions_ping",
		"endpoint": true,
		"params": [
			{
				"name": "status",
				"value": "",
				"optional": true,
				"options": ["", "active", "idle"],
			},
		],
	},
	{
		"name": "sessions_check",
		"endpoint": true,
	},
	{
		"name": "sessions_close",
		"endpoint": true,
	},

	# Scores
	{
		"name": "Scores",
		"section": true,
	},
	{
		"name": "scores_fetch",
		"endpoint": true,
		"params": [
			{
				"name": "limit",
				"value": "",
				"optional": true,
			},
			{
				"name": "table_id",
				"value": "",
				"optional": true,
			},
			{
				"name": "guest",
				"value": "",
				"optional": true,
			},
			{
				"name": "better_than",
				"value": "",
				"optional": true,
			},
			{
				"name": "worse_than",
				"value": "",
				"optional": true,
			},
			{
				"name": "this_user",
				"value": true,
				"optional": true,
			},
		],
	},
	{
		"name": "scores_tables",
		"endpoint": true,
	},
	{
		"name": "scores_add",
		"endpoint": true,
		"params": [
			{
				"name": "score",
				"value": "",
			},
			{
				"name": "sort",
				"value": "",
			},
			{
				"name": "table_id",
				"value": "",
				"optional": true,
			},
			{
				"name": "guest",
				"value": "",
				"optional": true,
			},
			{
				"name": "extra_data",
				"value": "",
				"optional": true,
			},
		],
	},
	{
		"name": "scores_get_rank",
		"endpoint": true,
		"params": [
			{
				"name": "sort",
				"value": "",
			},
			{
				"name": "table_id",
				"value": "",
				"optional": true,
			},
		],
	},

	# Trophies
	{
		"name": "Trophies",
		"section": true,
	},
	{
		"name": "trophies_fetch",
		"endpoint": true,
		"params": [
			{
				"name": "achieved",
				"value": "false",
				"optional": true,
			},
			{
				"name": "trophy_ids",
				"value": [],
				"optional": true,
			},
		],
	},
	{
		"name": "trophies_add_achieved",
		"endpoint": true,
		"params": [
			{
				"name": "trophy_id",
				"value": "",
			},
		],
	},
	{
		"name": "trophies_remove_achieved",
		"endpoint": true,
		"params": [
			{
				"name": "trophy_id",
				"value": "",
			},
		],
	},

	# Data Storage
	{
		"name": "Data Storage",
		"section": true,
	},
	{
		"name": "data_store_set",
		"endpoint": true,
		"params": [
			{
				"name": "key",
				"value": "",
			},
			{
				"name": "data",
				"value": "",
			},
			{
				"name": "global_data",
				"value": false,
				"optional": true,
			},
		],
	},
	{
		"name": "data_store_update",
		"endpoint": true,
		"params": [
			{
				"name": "key",
				"value": "",
			},
			{
				"name": "operation",
				"value": "",
				"options": ["add", "subtract", "multiply", "divide", "append", "prepend"],
			},
			{
				"name": "value",
				"value": "",
			},
			{
				"name": "global_data",
				"value": false,
				"optional": true,
			},
		],
	},
	{
		"name": "data_store_remove",
		"endpoint": true,
		"params": [
			{
				"name": "key",
				"value": "",
			},
			{
				"name": "global_data",
				"value": false,
				"optional": true,
			},
		],
	},
	{
		"name": "data_store_fetch",
		"endpoint": true,
		"params": [
			{
				"name": "key",
				"value": "",
			},
			{
				"name": "global_data",
				"value": false,
				"optional": true,
			},
		],
	},
	{
		"name": "data_store_get_keys",
		"endpoint": true,
		"params": [
			{
				"name": "pattern",
				"value": "",
				"optional": true,
			},
			{
				"name": "global_data",
				"value": false,
				"optional": true,
			},
		],
	},

	# Friends
	{
		"name": "Friends",
		"section": true,
	},
	{
		"name": "friends",
		"endpoint": true,
	},

	# Time
	{
		"name": "Time",
		"section": true,
	},
	{
		"name": "time",
		"endpoint": true,
	},
]

# Built-in overrides
func _ready() -> void:
	_add_endpoint_controls()


# Private methods
func _add_endpoint_controls() -> void:
	for _child in _container_inputs.get_children():
		var child: Node = _child
		child.queue_free()

	for _endpoint in _endpoints:
		var endpoint: Dictionary = _endpoint

		if endpoint.get("section"):
			var section := _create_section(endpoint)
			_container_inputs.add_child(section)
			continue

		elif endpoint.get("global"):
			_global = endpoint.get("params", [])

		var container := _create_endpoint_container()
		_container_inputs.add_child(container)

		if endpoint.get("endpoint"):
			var button := _create_endpoint_button(endpoint)
			button.pressed.connect(_on_ButtonEndpoint_pressed.bind(endpoint))
			container.add_child(button)

		for _param in endpoint.get("params", []):
			var param: Dictionary = _param

			var control := _create_param_input(param)
			container.add_child(control)


# Creates the container to hold the endpoint button and its input controls.
func _create_endpoint_container() -> Container:
	var container := HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = CONTROL_RECT_MIN_SIZE
	return container


# Creates a button to call the endpoint.
func _create_endpoint_button(endpoint: Dictionary) -> Button:
	var button := Button.new()
	_set_control_size(button, false, 2.0)
	button.size_flags_stretch_ratio = 1.5
	button.text = endpoint["name"] + "(%s)" % ("..." if endpoint.get("params", []).size() else "")
	var param_hints := []

	for _param in endpoint.get("params", []):
		var param: Dictionary = _param
		var hint: String = _format_placeholder_text(param, true, true)

		param_hints.push_back(hint)

	button.tooltip_text = endpoint["name"] + "(%s)" % ", ".join(param_hints)
	return button


# Creates an input control based on the evaluated parameter type.
func _create_param_input(param: Dictionary) -> Control:
	var control: Control

	if typeof(param["value"]) in [TYPE_BOOL]:
		control = _create_param_input_bool(param)

	elif typeof(param["value"]) in [TYPE_INT]:
		control = _create_param_input_int(param)

	else:
		control = _create_param_input_string(param)

	control.tooltip_text = _format_placeholder_text(param, true, true)
	return control


# Creates a LineEdit input to handle strings and other types.
func _create_param_input_string(param: Dictionary) -> LineEdit:
	var line_edit := LineEdit.new()
	_set_control_size(line_edit)
	line_edit.placeholder_text = _format_placeholder_text(param)
	param["value"] = _get_literal(param["value"]) if typeof(param["value"]) == TYPE_STRING else param["value"]
	line_edit.text = JSON.stringify(param["value"]) if typeof(param["value"]) in [TYPE_ARRAY, TYPE_DICTIONARY] else str(param["value"])
	line_edit.text_changed.connect(_on_LineEdit_text_changed.bind(param))
	line_edit.secret = param.get("secret", false)
	return line_edit


# Creates a CheckBox input to handle boolean types.
func _create_param_input_bool(param: Dictionary) -> CheckBox:
	var check_box := CheckBox.new()
	_set_control_size(check_box)
	check_box.text = " " + _format_placeholder_text(param)
	check_box.toggled.connect(_on_CheckBox_toggled.bind(param))
	return check_box


# Creates a SpinBox input to handle integer types.
func _create_param_input_int(param: Dictionary) -> SpinBox:
	var spin_box := SpinBox.new()
	_set_control_size(spin_box)
	spin_box.prefix = _format_placeholder_text(param)
	spin_box.value_changed.connect(_on_SpinBox_value_changed.bind(param))
	return spin_box


# Creates a label to separate different sections of endpoints.
func _create_section(endpoint: Dictionary) -> Label:
	var label := Label.new()
	label.text = endpoint["name"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = CONTROL_RECT_MIN_SIZE #* 0.75
	return label


# Sets indexed property of object after parameter is set.
func _run_param_setter(param: Dictionary) -> void:
	if not param.get("object") or not param.get("property").length():
		return

	prints("Set", param["object"], ":", param["property"], "=", param["value"])
	param["object"].set_indexed(param["property"], param["value"])


# Event handlers
# Executed when the endpoint button is pressed.
func _on_ButtonEndpoint_pressed(endpoint: Dictionary) -> void:
	_text_edit_output.text = "Requesting " + endpoint["name"] + "..."
	var signal_name := GameJolt._operation_to_signal(endpoint["name"])
	var method_name := "_on_request_completed"
	var param_values := []

	for param in endpoint.get("params", []):
		param_values.push_back(param["value"])

	if not GameJolt.is_connected(signal_name, get(method_name)):
		GameJolt.connect(signal_name, get(method_name).bind(endpoint))

	prints("Run endpoint:", endpoint["name"], JSON.stringify(param_values))
	GameJolt.callv(endpoint["name"], param_values)


# Executed when a request returns its response.
func _on_request_completed(result: Dictionary, endpoint: Dictionary) -> void:
	var param_values := []

	for param in endpoint.get("params", []):
		param_values.push_back(JSON.stringify(param["value"]))

	_text_edit_output.text = "Result of " + endpoint["name"] + "(%s)" % (", ".join(param_values)) + ":\n\n" \
		+ JSON.stringify(result, "    ")


# Executed when a numeric input changes its value.
func _on_SpinBox_value_changed(_value: float, param: Dictionary) -> void:
	var value := int(_value)
	param["value"] = value
	_run_param_setter(param)


# Executed when a boolean input changes its value.
func _on_CheckBox_toggled(value: bool, param: Dictionary) -> void:
	param["value"] = value
	_run_param_setter(param)


# Executed when a string input changes its value.
func _on_LineEdit_text_changed(value: String, param: Dictionary) -> void:
	value = value.strip_edges()
	var old_value = param["value"]
	var new_value = value
	var allow_conversion := false

	if typeof(old_value) in [TYPE_ARRAY, TYPE_DICTIONARY] and JSON.parse_string(value):
		new_value = JSON.parse_string(value)

	elif typeof(old_value) == TYPE_INT and value.is_valid_int():
		new_value = value.to_int()

	elif str(value).to_lower() in ["true", "false", "null"]:
		new_value = _get_literal(value)
		allow_conversion = true

	param["value"] = new_value \
		if typeof(new_value) == typeof(old_value) or allow_conversion \
		else old_value

	_run_param_setter(param)


# Show and hide output field.
func _on_ButtonOutput_pressed() -> void:
	_text_edit_output.visible = not _text_edit_output.visible


# Helper methods
# Returns string representation of type.
func _typeof(value) -> String:
	if typeof(value) == TYPE_STRING:
		return "String"
	if typeof(value) == TYPE_INT:
		return "int"
	if typeof(value) == TYPE_ARRAY:
		return "Array"
	if typeof(value) == TYPE_BOOL:
		return "bool"
	return "Variant"


# Expand and fill control horizontally and vertically.
func _set_control_size(control: Control, expand := false, h_size := 1.0) -> void:
	if expand:
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL

	control.custom_minimum_size = Vector2(130 * h_size, CONTROL_RECT_MIN_SIZE.y)


# Format param text based on its name, optional, type and valid options.
func _format_placeholder_text(param: Dictionary, type := false, _options := false) -> String:
	var options := []

	if _options and param.get("options"):
		for option in param["options"]:
			option = "'%s'" % option if typeof(option) == TYPE_STRING else str(option)
			options.push_back(option)

	return str(param["name"]) + ("?" if param.get("optional") else "") \
		+ (": " + _typeof(param["value"]) if type else "") \
		+ (" = " + " | ".join(options) if options.size() else "")


# Get literal value from string, or return original value instead.
func _get_literal(value: String):
	if str(value).to_lower() in ["true", "false", "null"]:
		value = str(value).to_lower()
		return true if value == "true" else false if value == "false" else null
	return value
