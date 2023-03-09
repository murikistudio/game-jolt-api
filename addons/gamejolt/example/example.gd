extends Control


const INDENT := "    "
const WAIT_TEXT := "Requesting..."


onready var _line_edit_game_id: LineEdit = find_node("LineEditGameId")
onready var _line_edit_private_key: LineEdit = find_node("LineEditPrivateKey")
onready var _text_edit_input: TextEdit = find_node("TextEditInput")
onready var _text_edit_output: TextEdit = find_node("TextEditOutput")
onready var _input_data := {
	"game_id": GameJolt._game_id,
	"private_key": GameJolt._private_key,
	"user_name": "",
	"user_token": "",
	"users_fetch_user_ids": [],
	"sessions_ping_status": "active", # "active" or "idle"
	"batch_parallel": false,
	"batch_break_on_error": false,
}


func _ready() -> void:
	init_input_data()
	update_input_data()


func init_input_data() -> void:
	var lines := []

	for key in _input_data.keys():
		lines.push_back(key + " = " + str(_input_data[key]))

	_text_edit_input.text = "\n".join(lines)


func update_input_data() -> void:
	var lines := _text_edit_input.text.split("\n", false)

	for line in lines:
		line = line.split("=", false)
		var key: String = line[0].strip_edges() if line.size() == 2 else ""
		var value: String = line[1].strip_edges() if line.size() == 2 else ""
		var final_value

		if validate_json(value) == "":
			final_value = JSON.parse(value).result
		elif value.to_lower() in ["true", "false"]:
			final_value = value.to_lower() == "true"
		else:
			final_value = value

		_input_data[key] = final_value

	GameJolt._game_id = _input_data.get("game_id", "")
	GameJolt._private_key = _input_data.get("private_key", "")
	GameJolt.set_user_name(_input_data.get("user_name", ""))
	GameJolt.set_user_token(_input_data.get("user_token", ""))


func set_text_edit_output(result: Dictionary) -> void:
	_text_edit_output.text = JSON.print(result, INDENT)


func _on_TextEditInput_focus_exited() -> void:
	update_input_data()


func _on_ButtonTime_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.time(), "time_completed")
	set_text_edit_output(result)


func _on_ButtonFriends_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.friends(), "friends_completed")
	set_text_edit_output(result)


func _on_ButtonUsersAuth_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.users_auth(), "users_auth_completed")
	set_text_edit_output(result)


func _on_ButtonUsersFetch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.users_fetch(
			_input_data.get("user_name"),
			_input_data.get("users_fetch_user_ids")
		),
		"users_fetch_completed"
	)
	set_text_edit_output(result)


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


func _on_ButtonBatch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT

	GameJolt.batch_begin()
	GameJolt.time()
	GameJolt.users_auth()
	GameJolt.batch_end()

	var result: Dictionary = yield(
		GameJolt.batch(
			_input_data.get("batch_parallel"),
			_input_data.get("batch_break_on_error")
		),
		"batch_completed"
	)

	set_text_edit_output(result)

