extends Control


const INDENT := "    "


onready var _line_edit_game_id: LineEdit = find_node("LineEditGameId")
onready var _line_edit_private_key: LineEdit = find_node("LineEditPrivateKey")
onready var _text_edit_result: TextEdit = find_node("TextEditResult")


func _ready() -> void:
	_line_edit_game_id.text = ProjectSettings.get_setting("game_jolt/default/game_id")
	_line_edit_private_key.text = ProjectSettings.get_setting("game_jolt/default/private_key")


func _on_ButtonTime_pressed() -> void:
	var result: Dictionary = yield(GameJolt.time(), "time_completed")
	_text_edit_result.text = JSON.print(result, INDENT)


func _on_ButtonFriends_pressed() -> void:
	var result: Dictionary = yield(GameJolt.friends(), "friends_completed")
	_text_edit_result.text = JSON.print(result, INDENT)


func _on_LineEditGameId_text_changed(new_text: String) -> void:
	GameJolt._game_id = new_text


func _on_LineEditPrivateKey_text_changed(new_text: String) -> void:
	GameJolt._private_key = new_text


func _on_LineEditUserName_text_changed(new_text: String) -> void:
	GameJolt.user_name = new_text


func _on_LineEditUserToken_text_changed(new_text: String) -> void:
	GameJolt.user_token = new_text
