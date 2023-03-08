tool
extends EditorPlugin

const DEBUG := true

const DEFAULT_SETTINGS := [
	{
		"name": "game_jolt/default/game_id",
		"type": TYPE_STRING,
		"value": "",
	},
	{
		"name": "game_jolt/default/private_key",
		"type": TYPE_STRING,
		"value": "",
	},
]


func enable_plugin() -> void:
	add_autoload_singleton("GameJolt", "res://addons/gamejolt/gamejolt.gd")

	if not has_settings():
		add_default_settings()

	print("Game Jolt API: Plugin initialized")


func disable_plugin() -> void:
	remove_autoload_singleton("GameJolt")

	if DEBUG:
		remove_default_settings()

	print("Game Jolt API: Plugin cleaned up")


func has_settings() -> bool:

	for setting in DEFAULT_SETTINGS:
		if not ProjectSettings.has_setting(setting["name"]):
			return false

	return true


func add_default_settings():

	for _setting in DEFAULT_SETTINGS:
		var setting: Dictionary = _setting

		ProjectSettings.set(setting["name"], setting["value"])

		var property_info := {
			"name": setting["name"],
			"type": setting["type"],
		}

		if setting.has("hint"):
			property_info["hint"] = setting["hint"]

		if setting.has("hint_string"):
			property_info["hint_string"] = setting["hint_string"]

		ProjectSettings.add_property_info(property_info)


func remove_default_settings():

	for _setting in DEFAULT_SETTINGS:
		var setting: Dictionary = _setting

		if ProjectSettings.has_setting(setting["name"]):
			ProjectSettings.clear(setting["name"])
