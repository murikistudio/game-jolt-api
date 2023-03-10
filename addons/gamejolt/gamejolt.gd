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
const REQUEST_ERROR_AWAIT_INTERVAL := 0.1
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
var _user_name := "" setget set_user_name, get_user_name
var _user_token := "" setget set_user_token, get_user_token
var _submit_requests := true
var _batch_requests := []

onready var _game_id: String = ProjectSettings.get_setting("game_jolt/default/game_id")
onready var _private_key: String = ProjectSettings.get_setting("game_jolt/default/private_key")


# Built-in overrides
func _ready() -> void:
	if OS.is_debug_build():
		set_user_name(ProjectSettings.get_setting("game_jolt/debug/user_name"))
		set_user_token(ProjectSettings.get_setting("game_jolt/debug/user_token"))


# Setters and getters
# Set the user name for auth and other user scope tasks.
func set_user_name(value: String) -> void:
	_user_name = value


# Get current user name.
func get_user_name() -> String:
	return _user_name


# Set the user token for auth and other user scope tasks.
func set_user_token(value: String) -> void:
	_user_token = value


# Get current user game token.
func get_user_token() -> String:
	return _user_token


# Public methods
# Batch Request
# Perform the batch request after gathering requests with batch_begin and batch end.
func batch(parallel := false, break_on_error := false) -> _GameJolt:
	if parallel and break_on_error:
		return _dispatch_local_error_response(
			"batch",
			"Values 'parallel' and 'break_on_error' are mutually exclusive"
		)

	for i in _batch_requests.size():
		var request: String = _batch_requests[i]
		request = request.replace(API_URL, "")
		request = request.split("&signature=")[0]
		request += "&signature=" + (request + _private_key).md5_text()
		_batch_requests[i] = request

	var data := {
		"game_id": _game_id,
		"requests": _batch_requests if _batch_requests.size() else null
	}

	var optional_data := {
		"parallel": parallel if parallel else null,
		"break_on_error": break_on_error if break_on_error else null,
	}

	_batch_requests = []

	return _submit("batch", data, optional_data)


# Begins to gather requests for batch. Methods will not return responses after this call.
func batch_begin() -> void:
	_submit_requests = false
	_batch_requests = []


# Stops gathering requests for batch. Methods will return responses again after this call.
func batch_end() -> void:
	_submit_requests = true


# Data Store
# Returns data from the data store.
func data_store_fetch(key: String, global_data := false) -> _GameJolt:
	var data = {
		"game_id" : _game_id,
		"key" : key,
	}

	var optional_data = {
		"username" : null if global_data else _user_name,
		"user_token" : null if global_data else _user_token
	}

	return _submit("data-store/fetch", data, optional_data)


# Returns either all the keys in the game's global data store, or all the keys in a user's data store.
func data_store_get_keys(pattern := "", global_data := false) -> _GameJolt:
	var data = {
		"game_id" : _game_id,
	}

	var optional_data = {
		"username" : null if global_data else _user_name,
		"user_token" : null if global_data else _user_token,
		"pattern": pattern,
	}

	return _submit("data-store/get-keys", data, optional_data)


# Removes data from the data store.
func data_store_remove(key: String, global_data := false) -> _GameJolt:
	var data = {
		"game_id" : _game_id,
		"key" : key,
	}

	var optional_data = {
		"username" : null if global_data else _user_name,
		"user_token" : null if global_data else _user_token
	}

	return _submit("data-store/remove", data, optional_data)


# Sets data in the data store.
func data_store_set(key: String, data, global_data := false) -> _GameJolt:
	data = _data_to_string(data)

	var data_ = {
		"game_id" : _game_id,
		"key" : key,
		"data" : data,
	}

	var optional_data = {
		"username" : null if global_data else _user_name,
		"user_token" : null if global_data else _user_token
	}

	return _submit("data-store/set", data_, optional_data)


# Updates data in the data store.
func data_store_update(key: String, operation: String, value, global_data := false) -> _GameJolt:
	var data = {
		"game_id" : _game_id,
		"key" : key,
		"operation" : operation,
		"value" : value,
	}

	var optional_data = {
		"username" : null if global_data else _user_name,
		"user_token" : null if global_data else _user_token
	}

	return _submit("data-store/update", data, optional_data)


# Friends
# Returns the list of a user's friends.
func friends() -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
	}

	return _submit("friends", data)


# Scores
# Adds a score for a user or guest.
func scores_add(score: String, sort, table_id = null, guest := "", extra_data = null) -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"score": score,
		"sort": sort,
	}

	extra_data = _data_to_string(extra_data)

	var optional_data := {
		"username": guest if guest else _user_name,
		"user_token": null if guest else _user_token,
		"table_id": table_id if table_id else null,
		"guest": guest if guest else null,
		"extra_data": extra_data if extra_data else null,
	}

	return _submit("scores/add", data, optional_data)


# Returns a list of scores either for a user or globally for a game.
func scores_fetch(limit = null, table_id = null, guest := "", better_than = null, worse_than = null, this_user := false) -> _GameJolt:
	var data := {
		"game_id": _game_id,
	}

	var optional_data := {
		"username": _user_name if this_user else guest if guest else null,
		"user_token": _user_token if this_user else null,
		"limit":  limit if limit else null,
		"table_id":  table_id if table_id else null,
		"guest": guest if guest else null,
		"better_than": better_than if better_than else null,
		"worse_than": worse_than if worse_than else null,
	}

	if optional_data.get("username") and optional_data.get("guest"):
		return _dispatch_local_error_response(
			"scores/fetch",
			"Parameters 'username' and 'guest' are mutually exclusive"
		)

	return _submit("scores/fetch", data, optional_data)


# Returns the rank of a particular score on a score table.
func scores_get_rank(sort: int, table_id := "") -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"sort": sort,
	}

	var optional_data := {
		"table_id": table_id if table_id else null,
	}

	return _submit("scores/get-rank", data, optional_data)


# Returns a list of high score tables for a game.
func scores_tables() -> _GameJolt:
	var data := {
		"game_id": _game_id,
	}

	return _submit("scores/tables", data)


# Sessions
# Checks to see if there is an open session for the user.
func sessions_check() -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
	}

	return _submit("sessions/check", data)


# Closes the active session.
func sessions_close() -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
	}

	return _submit("sessions/close", data)


# Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.
func sessions_open() -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
	}

	return _submit("sessions/open", data)


# Pings an open session to tell the system that it's still active.
func sessions_ping(status := "") -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
	}

	if status:
		if not status in ["active", "idle"]:
			return _dispatch_local_error_response(
				"sessions/ping",
				"Ping status must be 'active' or 'idle'"
			)

		data["status"] = status

	return _submit("sessions/ping", data)


# Time
# Returns the time of the Game Jolt server.
func time() -> _GameJolt:
	var data := {
		"game_id": _game_id,
	}

	return _submit("time", data)


# Trophies
# Returns one trophy or multiple trophies, depending on the parameters passed in.
func trophies_fetch(achieved = null, trophy_ids := []) -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
	}

	var optional_data := {
		"achieved": achieved,
		"trophy_id": ",".join(trophy_ids) if trophy_ids.size() else null,
	}

	return _submit("trophies/fetch", data, optional_data)


# Sets a trophy as achieved for a particular user.
func trophies_add_achieved(trophy_id):
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
		"trophy_id": trophy_id,
	}

	return _submit("trophies/add-achieved", data)


# Remove a previously achieved trophy for a particular user.
func trophies_remove_achieved(trophy_id):
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
		"trophy_id": trophy_id,
	}

	return _submit("trophies/remove-achieved", data)


# Users
# Authenticates the user's information.
func users_auth() -> _GameJolt:
	var data := {
		"game_id": _game_id,
		"username": _user_name,
		"user_token": _user_token,
	}

	return _submit("users/auth", data)


# Returns a user's data.
func users_fetch(_user_name := "", _user_ids := []):
	var data := {
		"game_id": _game_id,
	}

	if _user_name:
		data["username"] = _user_name

	elif _user_ids.size():
		for i in _user_ids.size():
			_user_ids[i] = str(_user_ids[i])

		data["user_id"] = ",".join(_user_ids)

	else:
		data["username"] = _user_name

	return _submit("users/fetch", data)


# Private methods
# Submit request and return response data on specific signal.
func _submit(operation: String, data: Dictionary, optional_data := {}) -> _GameJolt:
	if optional_data.size():
		data.merge(_validate_optional_data(optional_data))

	var required_data_error := _validate_required_data(data)
	var final_url := _generate_url(OPERATIONS[operation], data)
	if DEBUG: prints(final_url)

	if not _submit_requests:
		_batch_requests.push_back(final_url)
		return self

	if required_data_error:
		return _dispatch_local_error_response(operation, required_data_error)

	var http_request := _create_http_request()

	http_request.request(final_url, HEADERS, true, HTTPClient.METHOD_GET)
	http_request.connect(
		"request_completed", self, "_on_HTTPRequest_request_completed",
		[operation, http_request], CONNECT_ONESHOT
	)

	return self


# Create and return HTTPRequest node to perform request.
func _create_http_request() -> HTTPRequest:
	var _http_request := HTTPRequest.new()
	add_child(_http_request)
	_http_request.use_threads = true
	return _http_request


# Await a fraction of a second before emiting an local error response to the user.
func _dispatch_local_error_response(operation: String, message: String) -> _GameJolt:
	get_tree().create_timer(REQUEST_ERROR_AWAIT_INTERVAL).connect(
		"timeout", self, "_on_TimerFailed_timeout",
		[operation, {"success": false, "message": message}]
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
func _validate_required_data(data: Dictionary) -> String:
	for key in data.keys():
		var value = data[key]

		if typeof(value) == TYPE_NIL or typeof(value) == TYPE_STRING and not value:
			return MESSAGE_ERROR_DATA_REQUIRED + str(key)

		if typeof(value) == TYPE_BOOL:
			data[key] = str(value).to_lower()

	return ""


# Discard null values from optional data and perform conversions.
func _validate_optional_data(data: Dictionary) -> Dictionary:
	var valid_data := {}

	for key in data.keys():
		var value = data[key]

		if typeof(value) == TYPE_NIL or typeof(value) == TYPE_STRING and not value:
			continue

		if typeof(value) == TYPE_BOOL:
			value = str(value).to_lower()

		valid_data[key] = value

	return valid_data


# Encode and join URL params.
func _params_encode(data: Dictionary, requests := []) -> String:
	var params := []

	for key in data.keys():
		params.push_back(key + "=" + str(data[key]).percent_encode())

	for request in requests:
		params.push_back("requests[]=" + request.percent_encode())

	return "&".join(params)


# Convert generic data to string in the best way possible.
func _data_to_string(data) -> String:
	if typeof(data) in [TYPE_ARRAY, TYPE_DICTIONARY]:
		data = JSON.print(data)
	elif typeof(data) == TYPE_BOOL:
		data = str(data).to_lower()
	else:
		data = str(data)

	return data


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
	var signal_prefix := operation.replace("/", "_").replace("-", "_")

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
