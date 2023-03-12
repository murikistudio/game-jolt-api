extends Control


# Constants
const CONTROL_RECT_MIN_SIZE := Vector2(0, 32)


# Variables
onready var _text_edit_output: TextEdit = find_node("TextEditOutput")
onready var _container_inputs: Container = find_node("ContainerInputs")
onready var _methods := [
	{
		"name": "Users",
		"section": true,
	},
	{
		"name": "users_fetch",
		"params": [
			{
				"name": "user_name",
				"value": "",
			},
			{
				"name": "user_ids",
				"value": [],
			},
		],
	},
	{
		"name": "users_auth",
		"params": [],
	},
]

# Built-in overrides
func _ready() -> void:
	_add_method_controls()


# Private methods
func _add_method_controls() -> void:
	for _method in _methods:
		var method: Dictionary = _method

		if method.get("section"):
			var section := _create_section(method)
			_container_inputs.add_child(section)
			continue

		var container := _create_method_container(method)
		_container_inputs.add_child(container)

		var button := _create_method_button(method)
		container.add_child(button)

		for _param in method["params"]:
			var param: Dictionary = _param

			var control := _create_param_input(param)
			container.add_child(control)



func _create_method_container(method: Dictionary) -> Container:
	var container := HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.rect_min_size = CONTROL_RECT_MIN_SIZE
	return container


func _set_control_size_flags(control: Control, horizontal := true, vertical := true) -> void:
	if horizontal:
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if vertical:
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _create_method_button(method: Dictionary) -> Button:
	var button := Button.new()
	_set_control_size_flags(button)
	button.size_flags_stretch_ratio = 1.5
	button.text = method["name"] + "(%s)" % ("..." if method["params"].size() else "")
	var param_hints := []

	for _param in method["params"]:
		var param: Dictionary = _param
		param_hints.push_back(param["name"] + ": " + _typeof(param["value"]))

	button.hint_tooltip = method["name"] + "(%s)" % ", ".join(param_hints)
	return button


func _create_param_input(param: Dictionary) -> Control:
	var control: Control

	if typeof(param["value"]) in [TYPE_BOOL]:
		control = _create_param_input_bool(param)

	elif typeof(param["value"]) in [TYPE_INT]:
		control = _create_param_input_int(param)

	else:
		control = _create_param_input_string(param)

	control.hint_tooltip = param["name"] + ": " + _typeof(param["value"])
	return control


func _create_param_input_string(param: Dictionary) -> LineEdit:
	var line_edit := LineEdit.new()
	_set_control_size_flags(line_edit)
	line_edit.placeholder_text = (param["name"] as String).capitalize()
	return line_edit


func _create_param_input_bool(param: Dictionary) -> CheckBox:
	var check_box := CheckBox.new()
	_set_control_size_flags(check_box)
	check_box.text = " " + (param["name"] as String).capitalize()
	return check_box


func _create_param_input_int(param: Dictionary) -> SpinBox:
	var spin_box := SpinBox.new()
	_set_control_size_flags(spin_box)
	spin_box.prefix = (param["name"] as String).capitalize()
	return spin_box


func _create_section(method: Dictionary) -> Label:
	var label := Label.new()
	label.text = method["name"]
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_BOTTOM
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.rect_min_size = CONTROL_RECT_MIN_SIZE * 0.75
	return label


# Helper methods
func _typeof(value) -> String:
	if typeof(value) == TYPE_STRING:
		return "String"
	if typeof(value) == TYPE_INT:
		return "int"
	if typeof(value) == TYPE_ARRAY:
		return "Array"
	return "Variant"
