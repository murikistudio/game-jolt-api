extends Node
class_name _GameJolt


# Inner classes
class GameJoltError extends Reference:

	# Raised when not all required data is provided in the request call.
	static func data_required(key: String) -> void:
		prints("Value is required, cannot be null:", str(key))


	# Raised when a value cannot be provided along with another.
	static func data_collision(keys: Array) -> void:
		prints("Values cannot be used together:", str(keys))


# Signals
signal time_completed(response)
signal friends_completed(response)


# Constants
const DEBUG := true
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
func users_auth():
	pass


func users_fetch(user_name := "", user_id := ""):
	pass


# Private methods
# Perform request and return data.
func _submit(operation: String, data: Dictionary) -> _GameJolt:
	if not _validate_required_data(data):
		emit_signal(operation.replace("/", "_") + "_completed", RESPONSE_FAILED)
		return self

	var final_url := _generate_url(OPERATIONS[operation], data)
	if DEBUG: print(final_url)

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
func _validate_required_data(data: Dictionary) -> bool:
	for key in data.keys():
		if typeof(data[key]) == TYPE_NIL or data[key] == "":
			GameJoltError.data_required(key)
			return false

	return true


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
		emit_signal(signal_prefix + "_completed", parsed_body)
		if DEBUG: print(parsed_body)
		return

	emit_signal(signal_prefix + "_completed", {"success": false})
