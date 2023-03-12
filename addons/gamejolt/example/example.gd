extends Control


const INDENT := "    "
const WAIT_TEXT := "Requesting..."
const SECRET_FIELDS := ["private_key", "user_token"]


onready var _line_edit_game_id: LineEdit = find_node("LineEditGameId")
onready var _line_edit_private_key: LineEdit = find_node("LineEditPrivateKey")
onready var _text_edit_output: TextEdit = find_node("TextEditOutput")
onready var _container_parameters: Container = find_node("ContainerParameters")
onready var _input_data := {
	"game_id": GameJolt._game_id,
	"private_key": GameJolt._private_key,
	"user_name": GameJolt.get_user_name(),
	"user_token": GameJolt.get_user_token(),
	"users_fetch_user_name": "",
	"users_fetch_user_ids": [],
	"sessions_ping_status": "active", # "active" or "idle"
	"scores_table_id": "714294",
	"scores_guest_name": "",
	"scores_fetch_this_user": false,
	"trophies_fetch_achieved": null,
	"trophies_fetch_trophy_ids": [],
	"trophies_trophy_id": "188176",
	"data_store_global_data": true,
	"data_store_key": "data_store_key",
	"data_store_value": "50",
	"data_store_get_keys_pattern": "data_*",
	"data_store_update_operation": "add",
	"batch_parallel": false,
	"batch_break_on_error": false,
}


func _ready() -> void:
	add_parameter_controls()
	update_parameters_data()


func update_parameters_data() -> void:
	GameJolt._game_id = _input_data.get("game_id", "")
	GameJolt._private_key = _input_data.get("private_key", "")
	GameJolt.set_user_name(_input_data.get("user_name", ""))
	GameJolt.set_user_token(_input_data.get("user_token", ""))


func set_text_edit_output(result: Dictionary) -> void:
	_text_edit_output.text = JSON.print(result, INDENT)


func add_parameter_controls() -> void:
	for key in _input_data.keys():
		var value = _input_data[key]
		var vbox_container := VBoxContainer.new()
		var control: Control
		var label: Label
		var normalized_text := (key as String).replace("_", " ").capitalize()

		if typeof(value) == TYPE_BOOL:
			var check_box := CheckBox.new()
			control = check_box
			check_box.text = " " + normalized_text
			check_box.pressed = value
			check_box.connect("toggled", self, "_on_CheckBox_toggled", [key])

		else:
			var line_edit := LineEdit.new()
			label = Label.new()
			control = line_edit
			line_edit.placeholder_text = normalized_text
			line_edit.text = str(value)
			line_edit.connect("text_changed", self, "_on_LineEdit_text_changed", [key])

			if key in SECRET_FIELDS:
				line_edit.secret = true

		if label:
			label.text = normalized_text
			label.align = Label.ALIGN_CENTER
			label.valign = Label.VALIGN_BOTTOM
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			vbox_container.add_child(label)

		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL

		vbox_container.rect_min_size.x = 130
		vbox_container.rect_min_size.y = 45
		vbox_container.add_child(control)
		_container_parameters.add_child(vbox_container)


# Event handlers
func _on_CheckBox_toggled(pressed: bool, property: String) -> void:
	_input_data[property] = pressed
	update_parameters_data()


func _on_LineEdit_text_changed(new_text: String, property: String) -> void:
	_input_data[property] = new_text
	update_parameters_data()


# Time
func _on_ButtonTime_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.time(), "time_completed")
	set_text_edit_output(result)


# Friends
func _on_ButtonFriends_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.friends(), "friends_completed")
	set_text_edit_output(result)


# Batch
func _on_ButtonBatch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT

	GameJolt.batch_begin()
	GameJolt.time()
	GameJolt.users_auth()
	GameJolt.batch_end()

	var result: Dictionary = yield(
		GameJolt.batch(
			_input_data.get("batch_parallel", false),
			_input_data.get("batch_break_on_error", false)
		),
		"batch_completed"
	)

	set_text_edit_output(result)


# Users
func _on_ButtonUsersAuth_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.users_auth(), "users_auth_completed")
	set_text_edit_output(result)


func _on_ButtonUsersFetch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.users_fetch(
			_input_data.get("users_fetch_user_name"),
			JSON.parse(JSON.print(_input_data.get("users_fetch_user_ids"))).result
		),
		"users_fetch_completed"
	)
	set_text_edit_output(result)


# Sessions
func _on_ButtonSessionsOpen_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.sessions_open(), "sessions_open_completed")
	set_text_edit_output(result)


func _on_ButtonSessionsPing_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.sessions_ping(_input_data.get("sessions_ping_status", "")),
		"sessions_ping_completed"
	)
	set_text_edit_output(result)


func _on_ButtonSessionsCheck_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.sessions_check(), "sessions_check_completed")
	set_text_edit_output(result)


func _on_ButtonSessionsClose_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.sessions_close(), "sessions_close_completed")
	set_text_edit_output(result)


# Trophies
func _on_ButtonTrophiesFetch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.trophies_fetch(
			_input_data.get("trophies_fetch_achieved", null),
			_input_data.get("trophies_fetch_trophy_ids", [])
		),
		"trophies_fetch_completed"
	)
	set_text_edit_output(result)


func _on_ButtonTrophiesAddAchieved_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.trophies_add_achieved(
			_input_data.get("trophies_trophy_id")
		),
		"trophies_add_achieved_completed"
	)
	set_text_edit_output(result)


func _on_ButtonTrophiesRemoveAchieved_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.trophies_remove_achieved(
			_input_data.get("trophies_trophy_id")
		),
		"trophies_remove_achieved_completed"
	)
	set_text_edit_output(result)


# Scores
func _on_ButtonScoresFetch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.scores_fetch(
			10,
			_input_data.get("scores_table_id", ""),
			_input_data.get("scores_guest_name", ""),
			0, 0, true
		),
		"scores_fetch_completed"
	)
	set_text_edit_output(result)


func _on_ButtonScoresTables_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	randomize()
	var score := int(rand_range(100, 10000))
	var result: Dictionary = yield(
		GameJolt.scores_tables(),
		"scores_tables_completed"
	)
	set_text_edit_output(result)


func _on_ButtonScoresAdd_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	randomize()
	var score := int(rand_range(100, 10000))
	var result: Dictionary = yield(
		GameJolt.scores_add(
			str(score) + " points",
			score,
			_input_data.get("scores_table_id", ""),
			_input_data.get("scores_guest_name", ""),
			'{"key": "value"}'
		),
		"scores_add_completed"
	)
	set_text_edit_output(result)


func _on_ButtonScoresGetRank_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.scores_get_rank(
			1, _input_data.get("scores_table_id", "")
		),
		"scores_get_rank_completed"
	)
	set_text_edit_output(result)


# Data Storage
func _on_ButtonDataStoreFetch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.data_store_fetch(
			_input_data.get("data_store_key", ""),
			_input_data.get("data_store_global_data", true)
		),
		"data_store_fetch_completed"
	)
	set_text_edit_output(result)


func _on_ButtonDataStoreGetKeys_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.data_store_get_keys(
			_input_data.get("data_store_get_keys_pattern", ""),
			_input_data.get("data_store_global_data", true)
		),
		"data_store_get_keys_completed"
	)
	set_text_edit_output(result)


func _on_ButtonDataStoreRemove_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.data_store_remove(
			_input_data.get("data_store_key", ""),
			_input_data.get("data_store_global_data", true)
		),
		"data_store_remove_completed"
	)
	set_text_edit_output(result)


func _on_ButtonDataStoreSet_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.data_store_set(
			_input_data.get("data_store_key", ""),
			_input_data.get("data_store_value", ""),
			_input_data.get("data_store_global_data", true)
		),
		"data_store_set_completed"
	)
	set_text_edit_output(result)


func _on_ButtonDataStoreUpdate_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.data_store_update(
			_input_data.get("data_store_key", ""),
			_input_data.get("data_store_update_operation", ""),
			_input_data.get("data_store_value", ""),
			_input_data.get("data_store_global_data", true)
		),
		"data_store_update_completed"
	)
	set_text_edit_output(result)
