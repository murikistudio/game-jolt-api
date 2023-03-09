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
	"user_ids": [],
}


func _ready() -> void:
	init_input_data()


func init_input_data() -> void:
	var lines := []

	for key in _input_data.keys():
		lines.push_back(key + " = " + str(_input_data[key]))

	_text_edit_input.text = "\n".join(lines)


func update_input_data(init := false) -> void:
	var lines := _text_edit_input.text.split("\n", false)

	for line in lines:
		line = line.split("=", false)
		var key: String = line[0].strip_edges() if line.size() == 2 else ""
		var value: String = line[1].strip_edges() if line.size() == 2 else ""
		var final_value

		if validate_json(value) == "":
			final_value = JSON.parse(value).result
		else:
			final_value = value

		_input_data[key] = final_value

	GameJolt._game_id = _input_data.get("game_id", "")
	GameJolt._private_key = _input_data.get("private_key", "")
	GameJolt.user_name = _input_data.get("user_name", "")
	GameJolt.user_token = _input_data.get("user_token", "")

	print(JSON.print(_input_data, "    "))


func _on_TextEditInput_focus_exited() -> void:
	print("update")
	update_input_data()


func _on_ButtonTime_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.time(), "time_completed")
	_text_edit_output.text = JSON.print(result, INDENT)


func _on_ButtonFriends_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.friends(), "friends_completed")
	_text_edit_output.text = JSON.print(result, INDENT)


func _on_ButtonUsersAuth_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(GameJolt.users_auth(), "users_auth_completed")
	_text_edit_output.text = JSON.print(result, INDENT)


func _on_ButtonUsersFetch_pressed() -> void:
	_text_edit_output.text = WAIT_TEXT
	var result: Dictionary = yield(
		GameJolt.users_fetch(
			_input_data.get("user_name"),
			_input_data.get("user_ids")
		),
		"users_fetch_completed"
	)
	_text_edit_output.text = JSON.print(result, INDENT)
