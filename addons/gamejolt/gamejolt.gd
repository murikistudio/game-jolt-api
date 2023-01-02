extends Node


# Signals
signal request_started(request, payload)
signal request_finished(request, response)
signal request_failed(request, error)


# Constants
const API_URL := "https://api.gamejolt.com/api/game/v1_2"
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


# Public attributes
var user_name := ""
var user_token := ""
var submit_requests := true

# On-ready public attributes
onready var game_id: String = ProjectSettings.get_setting("game_jolt/default/game_id")
onready var private_key: String = ProjectSettings.get_setting("game_jolt/default/private_key")


func _ready() -> void:
	print("Print: Game Jolt singleton ready")


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
func friends():
	pass


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
func time():
	pass


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

