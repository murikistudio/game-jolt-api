extends Node
class_name _GameJolt


# Signals
signal batch_completed(response)
signal data_store_fetch_completed(response)
signal data_store_get_keys_completed(response)
signal data_store_remove_completed(response)
signal data_store_set_completed(response)
signal data_store_update_completed(response)
signal friends_completed(response)
signal scores_add_completed(response)
signal scores_fetch_completed(response)
signal scores_get_rank_completed(response)
signal scores_tables_completed(response)
signal sessions_check_completed(response)
signal sessions_close_completed(response)
signal sessions_open_completed(response)
signal sessions_ping_completed(response)
signal time_completed(response)
signal trophies_add_achieved_completed(response)
signal trophies_fetch_completed(response)
signal trophies_remove_achieved_completed(response)
signal users_auth_completed(response)
signal users_fetch_completed(response)


# Constants
const DEBUG := true
const MESSAGE_ERROR_DATA_REQUIRED := "Value is required: "
const MESSAGE_ERROR_DATA_COLLISION := "Values cannot be used together: "
const RESPONSE_FAILED := {"success": false}
const API_URL := "https://api.gamejolt.com/api/game/v1_2"
const HEADERS := ["Access-Control-Allow-Origin: *"]
const OPERATIONS := {
	"users/fetch": API_URL + "/users/" + "?",
	"users/auth": API_URL + "/users/auth/" + "?",
	"sessions/open": API_URL + "/sessions/open/" + "?",
	"sessions/ping": API_URL + "/sessions/ping/" + "?",
	"sessions/check": API_URL + "/sessions/check/" + "?",
	"sessions/close": API_URL + "/sessions/close/" + "?",
	"scores/fetch": API_URL + "/scores/" + "?",
	"scores/tables": API_URL + "/scores/tables/" + "?",
	"scores/add": API_URL + "/scores/add/" + "?",
	"scores/get-rank": API_URL + "/scores/get-rank/" + "?",
	"trophies/fetch": API_URL + "/trophies/" + "?",
	"trophies/add-achieved": API_URL + "/trophies/add-achieved/" + "?",
	"trophies/remove-achieved": API_URL + "/trophies/remove-achieved/" + "?",
	"data-store/set": API_URL + "/data-store/set/" + "?",
	"data-store/update": API_URL + "/data-store/update/" + "?",
	"data-store/remove": API_URL + "/data-store/remove/" + "?",
	"data-store/fetch": API_URL + "/data-store/" + "?",
	"data-store/get-keys": API_URL + "/data-store/get-keys/" + "?",
	"friends": API_URL + "/friends/" + "?",
	"time": API_URL + "/time/" + "?",
	"batch": API_URL + "/batch/" + "?",
}


# Variables
var user_name := ""
var user_token := ""
var submit_requests := true

onready var _game_id: String = ProjectSettings.get_setting("game_jolt/default/game_id")
onready var _private_key: String = ProjectSettings.get_setting("game_jolt/default/private_key")


func _ready() -> void:
	pass


func _create_http_request() -> HTTPRequest:
	var _http_request := HTTPRequest.new()
	add_child(_http_request)
	_http_request.use_threads = true
	return _http_request


# Batch Request
func batch(requests: PoolStringArray, parallel := false, break_on_error := false):
	pass


# Data Store
func data_store_fetch(key: String, global_data := false):
	pass


func data_store_get_keys(pattern := "", global_data := false):
	pass


func data_store_remove(key: String, global_data := false):
	pass


func data_store_set(key: String, data: Dictionary, global_data := false):
	pass


func data_store_update(key: String, operation: String, value: String, global_data := false):
	pass


# Friends
func friends() -> _GameJolt:
	var data = {
		"game_id": _game_id,
		"username": user_name,
		"user_token": user_token,
	}

	return _submit("friends", data)


# Scores
func scores_add(score: String, sort: int, table_id := 0, guest := "", extra_data := ""):
	pass


func scores_fetch(limit := 0, table_id := 0, guest := "", better_than := 0, worse_than := 0, this_user := false):
	pass


func scores_get_rank(sort := 0, table_id := 0):
	pass


func scores_tables():
	pass


# Sessions
func sessions_check():
	pass


func sessions_close():
	pass


func sessions_open():
	pass


func sessions_ping(status := ""):
	pass


# Time
func time() -> _GameJolt:
	var data = {
		"game_id": _game_id,
	}

	return _submit("time", data)


# Trophies
func trophies_add_achieved(trophy_id: int):
	pass


func trophies_fetch(achieved: bool = true, trophy_id := 0):
	pass


func trophies_remove_achieved(trophy_id: int):
	pass


# Users
func users_auth() -> _GameJolt:
	var data = {
		"game_id": _game_id,
		"username": user_name,
		"user_token": user_token,
	}

	return _submit("users/auth", data)


func users_fetch(_user_name := "", _user_ids := []):
	var data = {
		"game_id": _game_id,
	}

	if _user_name:
		data["username"] = _user_name

	elif _user_ids.size():
		for i in _user_ids.size():
			_user_ids[i] = str(_user_ids[i])

		data["user_id"] = ",".join(_user_ids)

	else:
		data["username"] = user_name

	return _submit("users/fetch", data)


# Private methods
# Perform request and return data.
func _submit(operation: String, data: Dictionary) -> _GameJolt:
	var required_data_valid := _validate_required_data(data)
	var final_url := _generate_url(OPERATIONS[operation], data)
	if DEBUG: prints(final_url)

	if not required_data_valid["success"]:
		get_tree().create_timer(0.1).connect(
			"timeout", self, "_on_TimerFailed_timeout",
			[operation, required_data_valid]
		)
		return self

	var http_request := _create_http_request()

	http_request.request(final_url, HEADERS, true, HTTPClient.METHOD_GET)
	http_request.connect(
		"request_completed", self, "_on_HTTPRequest_request_completed",
		[operation, http_request], CONNECT_ONESHOT
	)

	return self


# Generate request URL from operation and data.
func _generate_url(operation_url: String, data: Dictionary) -> String:
	var is_batch := "batch" in operation_url
	var ordered_data := {}

	var keys_sorted := data.keys()
	keys_sorted.sort()

	for key in keys_sorted:
		ordered_data[key] = data[key]
	data = ordered_data

	var request_urls: Array = data.get("requests", [])
	data.erase("requests")
	var url_params := _params_encode(data, request_urls)

	var signature := (operation_url + url_params + _private_key).md5_text()
	return operation_url + url_params + "&signature=" + signature


# Validate if required data of request is provided.
func _validate_required_data(data: Dictionary) -> Dictionary:
	for key in data.keys():
		if typeof(data[key]) == TYPE_NIL or data[key] == "":
			return {
				"success": false,
				"message": MESSAGE_ERROR_DATA_REQUIRED + str(key)
			}

	return {"success": true}


# Discard null values from request data and ensure response format.
func _get_valid_data(data: Dictionary) -> Dictionary:
	var valid_data := {}

	for key in data.keys():
		if typeof(data[key]) == TYPE_NIL or data[key] == "":
			continue

		valid_data[key] = data[key]

	return valid_data


# Encode and join URL params.
func _params_encode(data: Dictionary, requests := []) -> String:
	var params := []

	for key in data.keys():
		params.push_back(key + "=" + str(data[key]).percent_encode())

	for request in requests:
		params.push_back("requests[]=" + request.percent_encode())

	return "&".join(params)


# Event handlers
# Executed when the request is finished.
func _on_HTTPRequest_request_completed(
	result: int,
	response_code: int,
	headers: PoolStringArray,
	body: PoolByteArray,
	operation: String,
	http_request: HTTPRequest
) -> void:
	var signal_prefix := operation.replace("/", "_")

	if result == HTTPRequest.RESULT_SUCCESS and response_code == HTTPClient.RESPONSE_OK:
		var parsed_body: Dictionary = JSON.parse(body.get_string_from_utf8()).result
		http_request.queue_free()

		if parsed_body and parsed_body["response"]:
			parsed_body = parsed_body["response"]
		else:
			parsed_body = RESPONSE_FAILED

		emit_signal(signal_prefix + "_completed", parsed_body)
		if DEBUG: prints(parsed_body)
		return

	emit_signal(signal_prefix + "_completed", RESPONSE_FAILED)


# Executed when a local error happens and the script must wait to respond.
func _on_TimerFailed_timeout(operation: String, data: Dictionary) -> void:
	if DEBUG: prints(data)
	emit_signal(operation.replace("/", "_") + "_completed", data)
